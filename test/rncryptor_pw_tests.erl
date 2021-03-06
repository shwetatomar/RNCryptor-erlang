-module(rncryptor_pw_tests).

-author("paul@dingosky.com").

-include_lib("eunit/include/eunit.hrl").

-define(PW_HMAC_KEY_SIZE,  32).    %%   128-bit

%%========================================================================================
%%
%% Password Encryption Tests
%%
%%========================================================================================

%%----------------------------------------------------------------------------------------
%%
%% Test vectors from RNCryptor v3:
%%
%%    https://github.com/RNCryptor/RNCryptor-Spec/blob/master/vectors/v3/password
%%
%%----------------------------------------------------------------------------------------
rn_spec_v3_all_fields_empty_or_zero_with_one_byte_password_encrypt_test() ->
  Password    = <<"a">>,
  HexKDFSalt  = "0000000000000000",
  HexHmacSalt = "0000000000000000",
  HexIVec     = "00000000000000000000000000000000",
  PlainText   = <<>>,
  Expected = "03010000000000000000000000000000000000000000000000000000000000000000B3039BE31CD7ECE5E754F5C8DA17003666313AE8A89DDCF8E3CB41FDC130B2329DBE07D6F4D32C34E050C8BD7E933B12",
  test_encrypt(Password, HexKDFSalt, HexIVec, HexHmacSalt, PlainText, Expected).

rn_spec_v3_all_fields_empty_or_zero_with_one_byte_password_decrypt_test() ->
  Password     = <<"a">>,
  HexRNCryptor = "03010000000000000000000000000000000000000000000000000000000000000000B3039BE31CD7ECE5E754F5C8DA17003666313AE8A89DDCF8E3CB41FDC130B2329DBE07D6F4D32C34E050C8BD7E933B12",
  Expected     = <<>>,
  test_decrypt(Password, HexRNCryptor, Expected).

rn_spec_v3_one_byte_password_encrypt_test() ->
  Password    = <<"thepassword">>,
  HexKDFSalt  = "0001020304050607",
  HexHmacSalt = "0102030405060708",
  HexIVec     = "02030405060708090a0b0c0d0e0f0001",
  PlainText   = <<1>>,
  Expected = "03010001020304050607010203040506070802030405060708090A0B0C0D0E0F0001A1F8730E0BF480EB7B70F690ABF21E029514164AD3C474A51B30C7EAA1CA545B7DE3DE5B010ACBAD0A9A13857DF696A8",
  test_encrypt(Password, HexKDFSalt, HexIVec, HexHmacSalt, PlainText, Expected).

rn_spec_v3_one_byte_password_decrypt_test() ->
  Password     = <<"thepassword">>,
  HexRNCryptor = "03010001020304050607010203040506070802030405060708090A0B0C0D0E0F0001A1F8730E0BF480EB7B70F690ABF21E029514164AD3C474A51B30C7EAA1CA545B7DE3DE5B010ACBAD0A9A13857DF696A8",
  Expected     = <<1>>,
  test_decrypt(Password, HexRNCryptor, Expected).

rn_spec_v3_exactly_one_block_password_encrypt_test() ->
  Password    = <<"thepassword">>,
  HexKDFSalt  = "0102030405060700",
  HexHmacSalt = "0203040506070801",
  HexIVec     = "030405060708090a0b0c0d0e0f000102",
  PlainText   = rncryptor_util:hex_to_bin("0123456789abcdef"),
  Expected = "030101020304050607000203040506070801030405060708090A0B0C0D0E0F0001020E437FE809309C03FD53A475131E9A1978B8EAEF576F60ADB8CE2320849BA32D742900438BA897D22210C76C35C849DF",
  test_encrypt(Password, HexKDFSalt, HexIVec, HexHmacSalt, PlainText, Expected).

rn_spec_v3_exactly_one_block_password_decrypt_test() ->
  Password     = <<"thepassword">>,
  HexRNCryptor = "030101020304050607000203040506070801030405060708090A0B0C0D0E0F0001020E437FE809309C03FD53A475131E9A1978B8EAEF576F60ADB8CE2320849BA32D742900438BA897D22210C76C35C849DF",
  Expected     = rncryptor_util:hex_to_bin("0123456789abcdef"),
  test_decrypt(Password, HexRNCryptor, Expected).

rn_spec_v3_more_than_one_block_password_encrypt_test() ->
  Password    = <<"thepassword">>,
  HexKDFSalt  = "0203040506070001",
  HexHmacSalt = "0304050607080102",
  HexIVec     = "0405060708090a0b0c0d0e0f00010203",
  PlainText   = rncryptor_util:hex_to_bin("0123456789ABCDEF01234567"),
  Expected = "0301020304050607000103040506070801020405060708090A0B0C0D0E0F00010203E01BBDA5DF2CA8ADACE38F6C588D291E03F951B78D3417BC2816581DC6B767F1A2E57597512B18E1638F21235FA5928C",
  test_encrypt(Password, HexKDFSalt, HexIVec, HexHmacSalt, PlainText, Expected).

rn_spec_v3_more_than_one_block_password_decrypt_test() ->
  Password     = <<"thepassword">>,
  HexRNCryptor = "0301020304050607000103040506070801020405060708090A0B0C0D0E0F00010203E01BBDA5DF2CA8ADACE38F6C588D291E03F951B78D3417BC2816581DC6B767F1A2E57597512B18E1638F21235FA5928C",
  Expected    = rncryptor_util:hex_to_bin("0123456789ABCDEF01234567"),
  test_decrypt(Password, HexRNCryptor, Expected).

rn_spec_v3_multibyte_password_encrypt_test() ->
  Password    = rncryptor_util:hex_to_bin("E4B8ADE69687E5AF86E7A081"),
  HexKDFSalt  = "0304050607000102",
  HexHmacSalt = "0405060708010203",
  HexIVec     = "05060708090a0b0c0d0e0f0001020304",
  PlainText   = rncryptor_util:hex_to_bin("23456789ABCDEF0123456701"),
  Expected = "03010304050607000102040506070801020305060708090A0B0C0D0E0F00010203048A9E08BDEC1C4BFE13E81FB85F009AB3DDB91387E809C4AD86D9E8A6014557716657BD317D4BB6A7644615B3DE402341",
  test_encrypt(Password, HexKDFSalt, HexIVec, HexHmacSalt, PlainText, Expected).

rn_spec_v3_multibyte_password_decrypt_test() ->
  Password     = rncryptor_util:hex_to_bin("E4B8ADE69687E5AF86E7A081"),
  HexRNCryptor = "03010304050607000102040506070801020305060708090A0B0C0D0E0F00010203048A9E08BDEC1C4BFE13E81FB85F009AB3DDB91387E809C4AD86D9E8A6014557716657BD317D4BB6A7644615B3DE402341",
  Expected     = rncryptor_util:hex_to_bin("23456789ABCDEF0123456701"),
  test_decrypt(Password, HexRNCryptor, Expected).

rn_spec_v3_longer_text_and_password_encrypt_test() ->
  Password    = <<"It was the best of times, it was the worst of times; it was the age of wisdom, it was the age of foolishness;">>,
  HexKDFSalt  = "0405060700010203",
  HexHmacSalt = "0506070801020304",
  HexIVec     = "060708090a0b0c0d0e0f000102030405",
  PlainText   = rncryptor_util:hex_to_bin("697420776173207468652065706F6368206F662062656C6965662C20697420776173207468652065706F6368206F6620696E63726564756C6974793B206974207761732074686520736561736F6E206F66204C696768742C206974207761732074686520736561736F6E206F66204461726B6E6573733B206974207761732074686520737072696E67206F6620686F70652C20697420776173207468652077696E746572206F6620646573706169723B207765206861642065766572797468696E67206265666F72652075732C20776520686164206E6F7468696E67206265666F72652075733B207765207765726520616C6C20676F696E67206469726563746C7920746F2048656176656E2C207765207765726520616C6C20676F696E6720746865206F74686572207761792E0A0A"),
  Expected = "030104050607000102030506070801020304060708090A0B0C0D0E0F000102030405D564C7A99DA921A6E7C4078A82641D95479551283167A2C81F31AB80C9D7D8BEB770111DECD3E3D29BBDF7EBBFC5F10AC87E7E55BFB5A7F487BCD39835705E83B9C049C6D6952BE011F8DDB1A14FC0C925738DE017E62B1D621CCDB75F2937D0A1A70E44D843B9C61037DEE2998B2BBD740B910232EEA71961168838F6995B9964173B34C0BCD311A2C87E271630928BAE301A8F4703AC2AE4699F3C285ABF1C55AC324B073A958AE52EE8C3BD68F919C09EB1CD28142A1996A9E6CBFF5F4F4E1DBA07D29FF66860DB9895A48233140CA249419D63046448DB1B0F4252A6E4EDB947FD0071D1E52BC15600622FA548A6773963618150797A8A80E592446DF5926D0BFD32B544B796F3359567394F77E7B171B2F9BC5F2CAF7A0FAC0DA7D04D6A86744D6E06D02FBE15D0F580A1D5BD16AD91348003611358DCB4AC9990955F6CBBBFB185941D4B4B71CE7F9BA6EFC1270B7808838B6C7B7EF17E8DB919B34FAC",
  test_encrypt(Password, HexKDFSalt, HexIVec, HexHmacSalt, PlainText, Expected).

rn_spec_v3_longer_text_and_password_decrypt_test() ->
  Password     = <<"It was the best of times, it was the worst of times; it was the age of wisdom, it was the age of foolishness;">>,
  HexRNCryptor = "030104050607000102030506070801020304060708090A0B0C0D0E0F000102030405D564C7A99DA921A6E7C4078A82641D95479551283167A2C81F31AB80C9D7D8BEB770111DECD3E3D29BBDF7EBBFC5F10AC87E7E55BFB5A7F487BCD39835705E83B9C049C6D6952BE011F8DDB1A14FC0C925738DE017E62B1D621CCDB75F2937D0A1A70E44D843B9C61037DEE2998B2BBD740B910232EEA71961168838F6995B9964173B34C0BCD311A2C87E271630928BAE301A8F4703AC2AE4699F3C285ABF1C55AC324B073A958AE52EE8C3BD68F919C09EB1CD28142A1996A9E6CBFF5F4F4E1DBA07D29FF66860DB9895A48233140CA249419D63046448DB1B0F4252A6E4EDB947FD0071D1E52BC15600622FA548A6773963618150797A8A80E592446DF5926D0BFD32B544B796F3359567394F77E7B171B2F9BC5F2CAF7A0FAC0DA7D04D6A86744D6E06D02FBE15D0F580A1D5BD16AD91348003611358DCB4AC9990955F6CBBBFB185941D4B4B71CE7F9BA6EFC1270B7808838B6C7B7EF17E8DB919B34FAC",
  Expected     = rncryptor_util:hex_to_bin("697420776173207468652065706F6368206F662062656C6965662C20697420776173207468652065706F6368206F6620696E63726564756C6974793B206974207761732074686520736561736F6E206F66204C696768742C206974207761732074686520736561736F6E206F66204461726B6E6573733B206974207761732074686520737072696E67206F6620686F70652C20697420776173207468652077696E746572206F6620646573706169723B207765206861642065766572797468696E67206265666F72652075732C20776520686164206E6F7468696E67206265666F72652075733B207765207765726520616C6C20676F696E67206469726563746C7920746F2048656176656E2C207765207765726520616C6C20676F696E6720746865206F74686572207761792E0A0A"),
  test_decrypt(Password, HexRNCryptor, Expected).

%%----------------------------------------------------------------------------------------
%%
%% Password encrypt/decrypt tests
%%
%%----------------------------------------------------------------------------------------
encrypt_decrypt_pw_1_test() ->
  Password    = <<"a">>,
  PlainText   = <<>>,
  test_encrypt_decrypt(Password, PlainText).

encrypt_decrypt_pw_2_test() ->
  Password    = <<"It was the best of times, it was the worst of times; it was the age of wisdom, it was the age of foolishness;">>,
  PlainText   = rncryptor_util:hex_to_bin("697420776173207468652065706F6368206F662062656C6965662C20697420776173207468652065706F6368206F6620696E63726564756C6974793B206974207761732074686520736561736F6E206F66204C696768742C206974207761732074686520736561736F6E206F66204461726B6E6573733B206974207761732074686520737072696E67206F6620686F70652C20697420776173207468652077696E746572206F6620646573706169723B207765206861642065766572797468696E67206265666F72652075732C20776520686164206E6F7468696E67206265666F72652075733B207765207765726520616C6C20676F696E67206469726563746C7920746F2048656176656E2C207765207765726520616C6C20676F696E6720746865206F74686572207761792E0A0A"),
  test_encrypt_decrypt(Password, PlainText).

%%========================================================================================
%%
%% Invalid args tests
%%
%%========================================================================================
encrypt_empty_pw_test() ->
  Password    = <<>>,
  PlainText   = <<"hey, now">>,
  Expected  = "Empty password",
  {error, Reason} = rncryptor:encrypt_pw(Password, PlainText),
  ?assertEqual(Expected, Reason).

decrypt_empty_pw_test() ->
  Password    = <<>>,
  RNCryptor = rncryptor_util:hex_to_bin("03010001020304050607010203040506070802030405060708090A0B0C0D0E0F0001A1F8730E0BF480EB7B70F690ABF21E029514164AD3C474A51B30C7EAA1CA545B7DE3DE5B010ACBAD0A9A13857DF696A8"),
  Expected  = "Empty password",
  {error, Reason} = rncryptor:decrypt_pw(Password, RNCryptor),
  ?assertEqual(Expected, Reason).

decrypt_invalid_rncryptor_type_test() ->
  Password    = <<"hey, now">>,
  RNCryptor = rncryptor_util:hex_to_bin("03000001020304050607010203040506070802030405060708090A0B0C0D0E0F0001A1F8730E0BF480EB7B70F690ABF21E029514164AD3C474A51B30C7EAA1CA545B7DE3DE5B010ACBAD0A9A13857DF696A8"),
  Expected  = "Invalid password-based RN cryptor",
  {error, Reason} = rncryptor:decrypt_pw(Password, RNCryptor),
  ?assertEqual(Expected, Reason).

decrypt_invalid_hmac_test() ->
  Password     = <<"thepassword">>,
  %% Twiddled last hex value from 'C' to 'D'
  RNCryptor = rncryptor_util:hex_to_bin("0301020304050607000103040506070801020405060708090A0B0C0D0E0F00010203E01BBDA5DF2CA8ADACE38F6C588D291E03F951B78D3417BC2816581DC6B767F1A2E57597512B18E1638F21235FA5928D"),
  Expected  = "Invalid Hmac",
  {error, Reason} = rncryptor:decrypt_pw(Password, RNCryptor),
  ?assertEqual(Expected, Reason).

decrypt_invalid_rncryptor_test() ->
  Password     = <<"thepassword">>,
  RNCryptor = rncryptor_util:hex_to_bin("0301020304050607"),
  Expected  = "Invalid password-based RN cryptor",
  {error, Reason} = rncryptor:decrypt_pw(Password, RNCryptor),
  ?assertEqual(Expected, Reason).

%%========================================================================================
%%
%% Convenience functions
%%
%%========================================================================================
test_encrypt(Password, HexKDFSalt, HexIVec, HexHmacSalt, PlainText, Expected) ->
  {KDFSalt, KDFKey, HmacSalt, HmacKey} = pw_derived_keys(Password, HexKDFSalt, HexHmacSalt),
  IVec = rncryptor_util:hex_to_bin(HexIVec),
  RNCryptor = rncryptor:encrypt_pw(KDFSalt, KDFKey, IVec, HmacSalt, HmacKey, PlainText),
  ?assertEqual(Expected, rncryptor_util:bin_to_hex(RNCryptor)).

test_decrypt(Password, HexRNCryptor, Expected) ->
  RNCryptor = rncryptor_util:hex_to_bin(HexRNCryptor),
  PlainText = rncryptor:decrypt_pw(Password, RNCryptor),
  ?assertEqual(Expected, PlainText).

test_encrypt_decrypt(Password, PlainTextIn) ->
  RNCryptor = rncryptor:encrypt_pw(Password, PlainTextIn),
  PlainTextOut = rncryptor:decrypt_pw(Password, RNCryptor),
  ?assertEqual(PlainTextIn, PlainTextOut).

pw_derived_keys(Password, HexKDFSalt, HexHmacSalt) ->
  KDFSalt  = rncryptor_util:hex_to_bin(HexKDFSalt),
  KDFKey   = rncryptor_kdf:pbkdf2(Password, KDFSalt),
  HmacSalt = rncryptor_util:hex_to_bin(HexHmacSalt),
  HmacKey  = rncryptor_kdf:pbkdf2(Password, HmacSalt),
  {KDFSalt, KDFKey, HmacSalt, HmacKey}.
  
