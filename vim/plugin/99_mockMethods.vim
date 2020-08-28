if has('ruby') == 0 || exists('g:is_mock_methods_loaded')
  finish
endif

let g:is_mock_methods_loaded = 1

ruby << RUBY
module MockMethods
  class Parameter
    def initialize
      @const = nil
      @unsigned = nil
      @type = nil
      @ref = nil
    end

    def const= value
      @const = 'const' if value
    end

    def unsigned= value
      @unsigned = 'unsigned' if value
    end

    def type= value
      @type = value.strip rescue nil
    end

    def ref= value
      @ref = value.strip rescue nil
    end

    def valid?
      not @type.nil? or not @unsigned.nil?
    end

    def to_s
      "#{@const} #{@unsigned} #{@type}#{@ref}".strip.squeeze(' ')
    end
  end

  def self.mockMethod input
    m = input.match(/([\w:&\*<> ]+\s+)(\w+)\(.*\)/)
    returnData = m[m.size-2]
    methodName = m[m.size-1]

    parameters = splitParameters(input.match(/\((.*)\)/)[1])

    "#{macroType(input)}#{parameters.size}(#{methodName}, #{returnType(returnData)}(#{join(parameters)}));".squeeze(' ')
  end

  def self.splitParameters text
    result = Array.new

    it = 0
    while it < text.size
      parameter, progress = buildParameter(text[it..text.size])
      result.push parameter if parameter.valid?
      it += progress + 1
    end
    result
  end

  def self.buildParameter text
    it = 0

    result = Parameter.new
    if m = text.match(/(^\s*const)/, it)
        result.const = true
        it += m[1].size
    end
    if m = text.match(/(^\s*unsigned)/, it)
        result.unsigned = true
        it += m[1].size
    end

    kt, braces = nil, 0
    while it < text.size
      if text[it].to_s.match(/\s/) and kt.nil?
        it += 1
        next
      end

      if text[it].to_s.match(/[\w:]/)
        kt = it if kt.nil?
      elsif kt and text[it].to_s.match(/[<\(\[]/)
        braces += 1
      elsif kt and braces > 0 and text[it].to_s.match(/[>\)\]]/)
        braces -= 1
      elsif kt and braces > 0 and text[it].to_s.match(/[\s,]/)
      else
        break
      end
      it += 1
    end

    result.type = text[kt..it-1] if kt

    if m = text.match(/(\s*&&|\s*[&\*])/, it)
      result.ref = m[1]
      it += m[1].size
    end

    [ result, text.index(',', it) || text.size ]
  end

  def self.join args
    args.join(', ')
  end

  def self.returnType returnData
    if m = returnData.match(/virtual (.*)/)
      returnData = m[1].strip
    end
    if m = returnData.match(/(.*)([&\*])/)
      returnData = m[1].strip + m[2].strip
    end
    returnData.strip
  end

  def self.macroType input
    if input.match(/([\w:&\*<> ]+\s+)(\w+)\(.*\)\s*const/)
      return 'MOCK_CONST_METHOD'
    end
    'MOCK_METHOD'
  end

  def self.exec
    text, _beg, _end = Common.getSelectedLines
    result = Enumerator.new { |e|
      text.join.split(';').each { |line|
        spaces = line.match(/^(\s*)/)[1]
        e << spaces + MockMethods.mockMethod(line)
      }
    }.to_a
    Common.overrideLines result, _beg, _end
  end
end
RUBY

vnoremap <leader>m :call C8_rubyRange('MockMethods::exec')<CR>
