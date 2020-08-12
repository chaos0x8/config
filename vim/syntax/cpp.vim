syn keyword gTest TEST TEST_F TEST_P TYPED_TEST EXPECT_CALL INSTANTIATE_TEST_CASE_P
syn match gTest /\<\(ASSERT\|EXPECT\)_\w\w*\>/
syn match gTest /\<MATCHER_P\(\|\d\)\>/
syn match gTest /\<MOCK_METHOD\d\>/
syn match gTest /\<MOCK_CONST_METHOD\d\>/
syn match gTest /\<RUN_ALL_TESTS\>/
syn match gTest /\<ON_CALL\>/
syn keyword libNamespaces std boost testing

hi def link gtest Macro
hi def link libNamespaces Structure
