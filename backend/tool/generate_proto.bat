@echo off

protoc ^
--proto_path=. ^
--dart_out=../lib/generated ^
../market_data_v3.proto

pause