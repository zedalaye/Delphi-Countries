program generate;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.Classes,
  System.Generics.Collections,
  System.IOUtils,
  superobject,
  Countries in 'src\Countries.pas';

const
  DATA_ROOT = '..\..\countries-data-json\data';
  COUNTRIES_ROOT = DATA_ROOT + '\countries';
  TRANSLATIONS_ROOT = DATA_ROOT + '\translations';

  COUNTRIES_INC    = '..\..\src\Countries.Data.inc';
  TRANSLATIONS_INC = '..\..\src\Countries.Translations.inc';
  LOCALES_INC      = '..\..\src\Countries.Locales.inc';
  LANG_INC         = '..\..\src\locales\countries-%s.inc'; // Language

{ Utilities }

procedure WriteBuilder(const FileName: string; Builder: TStringBuilder);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    var Preamble := TEncoding.UTF8.GetPreamble;
    F.WriteBuffer(Preamble, Length(Preamble));

    var Data := Builder.ToString;
    var Bytes := TEncoding.UTF8.GetBytes(Data);
    F.WriteBuffer(Bytes, Length(Bytes));
  finally
    F.Free;
  end;
end;

function DelphiString(const Value: string; Multiline: Boolean = True): string;

  function NewLine: string;
  begin
    if Multiline then
      Result := #13#10 + '  '
    else
      Result := ' ';
  end;

var
  Remaining: string;
begin
  Remaining := StringReplace(Value, #10, '\n', [rfReplaceAll]);

  { Split very long strings }
  Result := '';
  while Length(Remaining) > 120 do
  begin
    Result := Result + NewLine + QuotedStr(Copy(Remaining, 1, 120)) + ' +';
    Delete(Remaining, 1, 120);
  end;
  if (Length(Result) > 0) and Multiline then
    Result := Result + NewLine;

  Result := Result + QuotedStr(Remaining);
end;

{ Countries }

procedure ProcessCountry(Builder: TStringBuilder; const Code: string;
  const Data: ISuperObject);

  procedure RawAppend(const VarName, PropName, Value: string);
  begin
    Builder.Append(VarName).Append('.').AppendFormat('F%s', [PropName]).Append(' := ').Append(Value).AppendLine(';');
  end;

  procedure Append(const VarName, PropName, Value: string); overload;
  begin
    RawAppend(VarName, PropName, DelphiString(Value));
  end;

  procedure Append(const VarName, PropName: string; Value: Boolean); overload;
  begin
    RawAppend(VarName, PropName, BoolToStr(Value, True));
  end;

  procedure Append(const VarName, PropName: string; Value: Double); overload;
  begin
    RawAppend(VarName, PropName, FloatToStr(Value));
  end;

  procedure Append(const VarName, PropName: string; Value: Integer); overload;
  begin
    RawAppend(VarName, PropName, IntToStr(Value));
  end;

  procedure AppendGeoBounds(const VarName, PropName: string; const Bounds: ISuperObject);
  var
    L: TList<TCountryGeoBounds>;
    It: TSuperObjectIter;
  begin
    L := TList<TCountryGeoBounds>.Create;
    try
      if ObjectFindFirst(Bounds, It) then
      begin
        repeat
          var B: TCountryGeoBounds;
          B.Name := It.key;
          B.Lat := It.val.D['lat'];
          B.Lng := It.val.D['lng'];
          L.Add(B);
        until ObjectFindNext(It) = False;
        ObjectFindClose(It);
      end;

      Builder.Append('SetLength(').Append(VarName).Append('.').AppendFormat('F%s', [PropName]).Append(', ').Append(L.Count).AppendLine(');');
      for var I := 0 to L.Count -1 do
      begin
        Append(VarName, Format('%s[%d].Name', [PropName, I]), L[I].Name);
        Append(VarName, Format('%s[%d].Lat',  [PropName, I]), L[I].Lat);
        Append(VarName, Format('%s[%d].Lng',  [PropName, I]), L[I].Lng);
      end;
    finally
      L.Free;
    end;
  end;

  procedure AppendVATRates(const VarName, PropName: string; const Data: ISuperObject);
  var
    L: TList<TCountryVATRate>;
    It: TSuperObjectIter;
  begin
    L := TList<TCountryVATRate>.Create;
    try
      if ObjectFindFirst(Data, It) then
      begin
        repeat
          var R: TCountryVATRate;
          R.Name := It.key;
          case ObjectGetType(It.val) of
          stNull:
            SetLength(R.Rates, 0);
          stInt,
          stDouble,
          stCurrency:
            begin
              SetLength(R.Rates, 1);
              R.Rates[0] := It.val.AsCurrency;
            end;
          stArray:
            begin
              SetLength(R.Rates, It.val.AsArray.Length);
              for var I := 0 to It.val.AsArray.Length -1 do
              begin
                var Rate := It.val.AsArray[I];
                Assert(ObjectGetType(Rate) in [stInt, stDouble, stCurrency]);
                R.Rates[I] := It.val.AsArray[I].AsCurrency;
              end;
            end
          else
            Assert(False);
          end;
          L.Add(R);
        until ObjectFindNext(It) = False;
        ObjectFindClose(It);
      end;

      Builder.Append('SetLength(').Append(VarName).Append('.').AppendFormat('F%s', [PropName]).Append(', ').Append(L.Count).AppendLine(');');
      for var I := 0 to L.Count -1 do
      begin
        Append(VarName, Format('%s[%d].Name', [PropName, I]), L[I].Name);
        Builder.Append('SetLength(').Append(VarName).Append('.').AppendFormat('F%s[%d].Rates', [PropName, I]).Append(', ').Append(Length(L[I].Rates)).AppendLine(');');
        for var J := 0 to Length(L[I].Rates) -1 do
          Append(VarName, Format('%s[%d].Rates[%d]',  [PropName, I, J]), L[I].Rates[J]);
      end;
    finally
      L.Free;
    end;
  end;

  procedure AppendArray(const VarName, PropName: string; const Arr: ISuperObject);
  begin
    Assert(ObjectIsType(Arr, stArray));
    Builder.Append('SetLength(').Append(VarName).Append('.').AppendFormat('F%s', [PropName]).Append(', ').Append(Arr.AsArray.Length).AppendLine(');');
    for var I := 0 to Arr.AsArray.Length -1 do
      case ObjectGetType(Arr.AsArray[I]) of
        stString:   Append(VarName, Format('%s[%d]', [PropName, I]), Arr.AsArray[I].AsString);
        stInt:      Append(VarName, Format('%s[%d]', [PropName, I]), Arr.AsArray[I].AsInteger);
        stDouble,
        stCurrency: Append(VarName, Format('%s[%d]', [PropName, I]), Arr.AsArray[I].AsDouble);
      else
        Assert(False); { null and everything else is not supported }
      end;
  end;

var
  CountryVarName: string;

begin
  WriteLn('Processing ', Code, '...');
  Assert(Code = Data.S['alpha2']);

  CountryVarName := Format('C_%s', [Code]);

  Builder.Append('var ').Append(CountryVarName).Append(' := ').Append('TCountry.Create').AppendLine(';');
  Append(CountryVarName, 'AddressFormat', Data.S['address_format']);
  Append(CountryVarName, 'Alpha2', Data.S['alpha2']);
  Append(CountryVarName, 'Alpha3', Data.S['alpha3']);

  Append(CountryVarName, 'Continent', Data.S['continent']);
  Append(CountryVarName, 'CountryCode', Data.S['country_code']);
  Append(CountryVarName, 'CurrencyCode', Data.S['currency_code']);
  Append(CountryVarName, 'DistanceUnit', Data.S['distance_unit']);
  Append(CountryVarName, 'EEAMember', Data.B['eea_member']);
  Append(CountryVarName, 'EUMember',  Data.B['eu_member']);
  Append(CountryVarName, 'G7Member',  Data.B['g7_member']);
  Append(CountryVarName, 'G20Member', Data.B['g20_member']);
  Append(CountryVarName, 'GEC', Data.S['gec']);

  Append(CountryVarName, 'Geo.Latitude', Data.D['geo.latitude']);
  Append(CountryVarName, 'Geo.Longitude', Data.D['geo.longitude']);
  Append(CountryVarName, 'Geo.MaxLatitude', Data.D['geo.max_latitude']);
  Append(CountryVarName, 'Geo.MaxLongitude', Data.D['geo.max_longitude']);
  Append(CountryVarName, 'Geo.MinLatitude', Data.D['geo.min_latitude']);
  Append(CountryVarName, 'Geo.MinLongitude', Data.D['geo.min_longitude']);
  AppendGeoBounds(CountryVarName, 'Geo.Bounds', Data['geo.bounds']);

  Append(CountryVarName, 'GEC', Data.S['gec']);
  Append(CountryVarName, 'InternationalPrefix', Data.S['international_prefix']);
  Append(CountryVarName, 'IOC', Data.S['ioc']);
  Append(CountryVarName, 'ISOLongName', Data.S['iso_long_name']);
  Append(CountryVarName, 'ISOShortName', Data.S['iso_short_name']);

  AppendArray(CountryVarName, 'LanguagesOfficial', Data['languages_official']);
  AppendArray(CountryVarName, 'LanguagesSpoken', Data['languages_spoken']);
  AppendArray(CountryVarName, 'NationalDestinationCodeLengthts', Data['national_destination_code_lengths']);
  AppendArray(CountryVarName, 'NationalNumberLengths', Data['national_number_lengths']);

  Append(CountryVarName, 'NationalPrefix', Data.S['national_prefix']);
  Append(CountryVarName, 'Nationality', Data.S['nationality']);
  Append(CountryVarName, 'Number', Data.S['number']);
  Append(CountryVarName, 'PostalCode', Data.B['postal_code']);
  Append(CountryVarName, 'PostalCodeFormat', Data.S['postal_code_format']);
  Append(CountryVarName, 'Region', Data.S['region']);
  Append(CountryVarName, 'StartOfWeek', Data.S['start_of_week']);
  Append(CountryVarName, 'SubRegion', Data.S['subregion']);
  Append(CountryVarName, 'UnLocode', Data.S['un_locode']);

  AppendArray(CountryVarName, 'UnofficialNames', Data['unofficial_names']);

  AppendVATRates(CountryVarName, 'VATRates', Data['vat_rates']);
  Append(CountryVarName, 'WorldRegion', Data.S['world_region']);

  Builder.Append('RegisterCountry(').Append(CountryVarName).AppendLine(');');
  Builder.AppendLine;
end;

procedure ProcessFiles(Builder: TStringBuilder);
var
  Files: TArray<string>;
  It: TSuperObjectIter;
begin
  Files := TDirectory.GetFiles(COUNTRIES_ROOT, '*.json');
  WriteLn('Found ', Length(Files), ' files');

  for var F in Files do
  begin
    var Obj: ISuperObject := TSuperObject.ParseFile(F, True);
    if ObjectFindFirst(Obj, It) then
    begin
      repeat
        ProcessCountry(Builder, It.key, It.val);
      until ObjectFindNext(It) = False;
      ObjectFindClose(It);
    end;
  end;

  WriteLn('Done');
end;

procedure ProcessCountries;
var
  Builder: TStringBuilder;
begin
  WriteLn('Processing Countries...');
  Builder := TStringBuilder.Create;
  try
    ProcessFiles(Builder);
    WriteBuilder(ExpandFileName(COUNTRIES_INC), Builder);
  finally
    Builder.Free;
  end;
end;

{ Translations }

procedure ProcessTranslationData(const Lang: string; const Data: ISuperObject; Builder: TStringBuilder);
var
  It: TSuperObjectIter;
begin
  if ObjectFindFirst(Data, It) then
  begin
    repeat
      Builder.Append('RegisterTranslation(').Append(QuotedStr(Lang)).Append(', ')
                                            .Append(QuotedStr(It.key)).Append(', ')
                                            .Append(DelphiString(It.val.AsString, False)).AppendLine(');');
    until ObjectFindNext(It) = False;
    ObjectFindClose(It);
  end;
end;

procedure ProcessTranslationFile(const FileName, Lang, DefaultLocale: string;
  TranslBuilder, LocalesBuilder: TStringBuilder);
var
  Obj: ISuperObject;
  Builder: TStringBuilder;
begin
  Obj := TSuperObject.ParseFile(FileName, True);
  if Obj = nil then
  begin
    WriteLn('Cannot process ', FileName);
    Exit;
  end;

  WriteLn('Processing ', Lang, '...');

  Builder := TStringBuilder.Create;
  try
    ProcessTranslationData(Lang, Obj, Builder);

    var IncFile := Format(LANG_INC, [Lang]);
    WriteBuilder(ExpandFileName(IncFile), Builder);

    TranslBuilder.AppendFormat('{$if defined(LANG_%s) or defined(LANG_ALL)}', [Lang]).AppendLine
                 .AppendFormat('  {$include locales\%s}', [ExtractFileName(IncFile)]).AppendLine
                 .AppendLine('{$endif}');

    if Lang = DefaultLocale then
      LocalesBuilder.AppendFormat('{$define LANG_%s}', [Lang]).AppendLine
    else
      LocalesBuilder.AppendFormat('{.$define LANG_%s}', [Lang]).AppendLine
  finally
    Builder.Free;
  end;
end;

procedure ProcessTranslations(const DefaultLocale: string);
var
  Files: TArray<string>;
  TranslBuilder, LocalesBuilder: TStringBuilder;
begin
  WriteLn('Processing translations...');
  Files := TDirectory.GetFiles(TRANSLATIONS_ROOT, '*.json');
  WriteLn('Found ', Length(Files), ' files');

  TranslBuilder := TStringBuilder.Create;
  LocalesBuilder := TStringBuilder.Create;
  try
    TranslBuilder.AppendLine('// TCountries.DefaultLanguage property defines how TCountry.CommonName behaves')
                 .AppendFormat('TCountries.DefaultLocale := ''%s'';', [DefaultLocale]).AppendLine
                 .AppendLine
                 .AppendLine('// You may not need to change anything below this line')
                 .AppendLine;

    LocalesBuilder.AppendLine('// Activate or deactivate languages as needed')
                  .AppendLine('// Ensure that the default language defined in Countries.Translations.inc is active.')
                  .AppendLine
                  .AppendLine('// Shortcut: Activate this one to embed all available translations. May be set project wise in your .dproj')
                  .AppendLine('{.$define LANG_ALL}')
                  .AppendLine;

    for var F in Files do
    begin
      var N := ChangeFileExt(ExtractFileName(F), '');
      if Copy(N, 1, 10) = 'countries-' then
      begin
        var Lang := Copy(N, 11, MaxInt);
        ProcessTranslationFile(F, Lang, DefaultLocale, TranslBuilder, LocalesBuilder);
      end;
    end;

    WriteBuilder(TRANSLATIONS_INC, TranslBuilder);
    WriteBuilder(LOCALES_INC, LocalesBuilder);

  finally
    LocalesBuilder.Free;
    TranslBuilder.Free;
  end;

  WriteLn('Done.');
end;

{ Entrypoint }

var
  Lang: string;

begin
  try
    if not DirectoryExists(COUNTRIES_ROOT) then
    begin
      WriteLn('countries data is missing');
      WriteLn('You must check out the countries-data-json submodule');
      ExitCode := 1;
      Exit;
    end;

    if not DirectoryExists(TRANSLATIONS_ROOT) then
    begin
      WriteLn('translations data is missing');
      WriteLn('You must check out the countries-data-json submodule');
      ExitCode := 1;
      Exit;
    end;

    if ParamCount > 0 then
    begin
      var I := 1;
      while I <= ParamCount do
      begin
        var P := ParamStr(I);
        if (P = '--lang') or (P = '-l') then
        begin
          Inc(I);
          Lang := ParamStr(I);
        end;
        Inc(I);
      end;
    end;

    if Lang = '' then
      Lang := 'fr';

    ProcessCountries;
    ProcessTranslations(Lang);

    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
