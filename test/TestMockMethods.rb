#!/usr/bin/ruby

require 'test/unit'
require 'shoulda'

require_relative 'lib/Import'
eval Import.extractModuleFromVim("#{File.dirname(__FILE__)}/../vim/plugin/99_mockMethods.vim", 'MockMethods')

class MockMethodsTests < Test::Unit::TestCase
    context 'MockMethodsTests' do
        should 'mock single method without parameters' do
            [ 'void methodName();',
              'virtual void methodName();',
              'virtual void methodName() = 0;' ].each do |inputLine|
                assert_match('MOCK_METHOD(void, methodName, (), (override));', MockMethods.mockMethod(inputLine), "inputLine: #{inputLine}")
            end
        end

        should 'mock method with parameters' do
            [ 'int mName(int variable1, float variable2)',
              'virtual int mName(int variable1, float variable2) = 0;' ].each do |inputLine|
                assert_match('MOCK_METHOD(int, mName, (int, float), (override));', MockMethods.mockMethod(inputLine), "inputLine: #{inputLine}")
            end
        end

        should 'mock method with parameters in namespace' do
            [ 'namespace::type1 mName(names::type2 variable1, std::float variable2)',
              'virtual namespace::type1 mName(names::type2 variable1, std::float variable2) = 0;' ].each do |inputLine|
                assert_match('MOCK_METHOD(namespace::type1, mName, (names::type2, std::float), (override));', MockMethods.mockMethod(inputLine), "inputLine: #{inputLine}")
            end
        end

        should 'mock method with const& parameters' do
            [ 'const T1& method(const T2& var1, const T3 var2)',
              'const T1 & method(const T2 & var1, const T3 var2)',
              'virtual const T1& method(const T2& var1, const T3 var2) = 0;' ].each do |inputLine|
                assert_match('MOCK_METHOD(const T1&, method, (const T2&, const T3), (override));', MockMethods.mockMethod(inputLine), "inputLine: #{inputLine}")
            end
        end

        should 'mock const method with parameters' do
            assert_match('MOCK_METHOD(void, method, (int), (const, override));', MockMethods.mockMethod('void method(int value) const;'))
        end

        should 'mock method with const* parameters' do
            assert_match('MOCK_METHOD(const T1*, method, (const T2*, const T3), (override));', MockMethods.mockMethod('const T1* method(const T2* var1, const T3 var2);'))
            assert_match('MOCK_METHOD(const T1*, method, (const T2*, const T3), (const, override));', MockMethods.mockMethod('const T1* method(const T2* var1, const T3 var2) const;'))
        end

        should 'mock method with template parameters' do
            assert_match('MOCK_METHOD(std::unique_ptr<int>, method, (const std::shared_ptr<float>&, const T3), (override));', MockMethods.mockMethod('std::unique_ptr<int> method(const std::shared_ptr<float>& var1, const T3 var2);'))
        end

        should 'mock method with unsigned parameters' do
            assert_match('MOCK_METHOD(unsigned int, method, (unsigned char, unsigned, uint32_t), (override));', MockMethods.mockMethod('unsigned int method(unsigned char a1, unsigned, uint32_t);'))
        end

        should 'mock method with function parameters' do
            assert_match('MOCK_METHOD(void, m, (std::function<void ()>), (override));', MockMethods.mockMethod('void m(std::function<void ()> a1);'))
            assert_match('MOCK_METHOD(void, m, (std::function<void (int, float)>), (override));', MockMethods.mockMethod('void m(std::function<void (int, float)> a1);'))
        end

        should 'mock method with && parameters' do
            assert_match('MOCK_METHOD(void, m, (T2&&, T3&&), (override));', MockMethods.mockMethod('void m(T2&& var1, T3 && var2);'))
        end
    end
end
