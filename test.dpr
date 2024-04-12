program test;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  Winapi.Windows,
  System.SysUtils,
  Countries in 'src\Countries.pas';

function Member(const &Of: string; Member: Boolean): string;
begin
  if Member then
    Result := &Of
  else
    Result := '';
end;

function Map(const &In: TArray<Integer>): TArray<string>; overload;
begin
  Setlength(Result, Length(&In));
  for var I := 0 to Length(&In) -1 do
    Result[I] := IntToStr(&In[I]);
end;

function Map(const &In: TArray<Currency>): TArray<string>; overload;
begin
  Setlength(Result, Length(&In));
  for var I := 0 to Length(&In) -1 do
    Result[I] := CurrToStr(&In[I]);
end;

function Map(const &In: TArray<TCountry>; const MapFunc: TFunc<TCountry, string>): TArray<string>; overload;
begin
  SetLength(Result, Length(&In));
  for var I := 0 to Length(&In) -1 do
    Result[I] := MapFunc(&In[I]);
end;

procedure DumpCountry(C: TCountry);
begin
  WriteLn(C.Alpha2, ': ', C.CommonName);
  WriteLn('Alpha2: ', C.Alpha2, ', Alpha3: ', C.Alpha3, ', GEC: ', C.GEC, ', IOC: ', C.IOC, ', UN/LOCODE: ', C.UnLocode);
  WriteLn('ISO Long Name: ', C.ISOLongName, ', Short Name: ', C.ISOShortName);
  WriteLn('Unofficial Names: [', string.Join(', ', C.UnofficialNames), ']');
  WriteLn('Translations');
  for var L in TCountries.Locales do
    WriteLn(' ', L, ': ', C.Translation[L]);
  WriteLn('Geo [', FloatToStr(C.Geo.Latitude), ', ', FloatToStr(C.Geo.Longitude), ']');
  WriteLn('Bounds { Min [', FloatToStr(C.Geo.MinLatitude), ', ', FloatToStr(C.Geo.MinLongitude), '], ',
                   'Max [', FloatToStr(C.Geo.MaxLatitude), ', ', FloatToStr(C.Geo.MaxLongitude), '] }');
  for var B in C.Geo.Bounds do
    WriteLn(' ', B.Name, ' [', FloatToStr(B.Lat), ', ', FloatToStr(B.Lng), ']');

  WriteLn('Continent: ', C.Continent, ', WorldRegion: ', C.WorldRegion, ', Region: ', C.Region, ', SubRegion: ', C.SubRegion);
  WriteLn('Membership: ', string.Join(', ', [
    Member('EU Member', C.IsEUMember), Member('EEA Member', C.IsEEAMember),
    Member('G7 Member', C.IsG7Member), Member('G20 Member', C.IsG20Member)
  ]));
  WriteLn('Compliancy: ', Member('GDPR Compliant', C.GDPRCompliant));
  WriteLn('Telephone');
  WriteLn(' Country Code: ', C.CountryCode);
  WriteLn(' International Prefix: ', C.InternationalPrefix);
  WriteLn(' National Prefix: ', C.NationalPrefix);
  WriteLn(' National Destination Code Lengthts: [', string.Join(', ', Map(C.NationalDestinationCodeLengthts)), ']');
  WriteLn(' National Number Lengths: [', string.Join(', ', Map(C.NationalNumberLengths)), ']');
  WriteLn('Distance Unit: ', C.DistanceUnit);
  WriteLn('Currency Code: ', C.CurrencyCode);
  WriteLn('VAT Rates');
  for var R in C.VATRates do
    WriteLn(' ', R.Name, ' [', string.join(', ', Map(R.Rates)), ']');
  WriteLn('Postal Code: ', Member('Has Postal Code', C.HasPostalCode));
  WriteLn(' Format: ', C.PostalCodeFormat);
  WriteLn(' Regexp: ', C.PostalCodeRegexp);
  WriteLn('Address Format: ', C.AddressFormat);
  WriteLn('Nationality: ', C.Nationality);
  WriteLn('Official Languages: [', string.Join(', ', C.LanguagesOfficial), ']');
  WriteLn('Languages Spoken: [', string.Join(', ', C.LanguagesSpoken), ']');
  WriteLn('Start of Week: ', C.StartOfWeek);
  WriteLn('Unicode Flag: ', C.EmojiFlag);
end;

procedure TestFrance;
var
  C, C1: TCountry;
begin
  C := TCountries.FindCountryByAnyName('france');
  Assert(C <> nil);
  C1 := TCountries.FindCountryByAnyName('FRANCE');
  Assert(C1 = C);
  C1 := TCountries.FindCountryByAnyName('FrAnCe');
  Assert(C1 = C);
  C1 := TCountries.FindCountryByAnyName('フランス');
  Assert(C1 = C);

  C1 := TCountries.FindCountryByCommonName('FrancE');
  Assert(C1 = C);
  C1 := TCountries.FindCountryByShortName('France');
  Assert(C1 = C);
  C1 := TCountries.FindCountryByLongName('France');
  Assert(C1 = nil);
  C1 := TCountries.FindCountryByUnofficialName('France');
  Assert(C1 = C);

  DumpCountry(C);
end;

procedure TestEuropeRegion;
var
  A: TCountryArray;
begin
  A := TCountries.AllByContinent('europe');
  WriteLn('Europe (Continent): ', Length(A), ' [', string.Join(', ', Map(A,
    function(C: TCountry): string
    begin
      Result := Format('%s (%s)', [C.Alpha2, C.CommonName])
    end
  )), ']');

  A := TCountries.AllByWorldRegion('emea');
  WriteLn('EMEA (WorldRegion): ', Length(A), ' [', string.Join(', ', Map(A,
    function(C: TCountry): string
    begin
      Result := Format('%s (%s)', [C.Alpha2, C.CommonName])
    end
  )), ']');

  A := TCountries.AllByRegion('europe');
  WriteLn('Europe (Region): ', Length(A), ' [', string.Join(', ', Map(A,
    function(C: TCountry): string
    begin
      Result := Format('%s (%s)', [C.Alpha2, C.CommonName])
    end
  )), ']');

  A := TCountries.AllBySubRegion('western europe');
  WriteLn('Western Europe (SubRegion): ', Length(A), ' [', string.Join(', ', Map(A,
    function(C: TCountry): string
    begin
      Result := Format('%s (%s)', [C.Alpha2, C.CommonName])
    end
  )), ']');
end;

procedure TestBasic;
var
  C: TCountry;
begin
  C := TCountries.Get('FR');
  Assert(C <> nil);
  Assert(C.Alpha2 = 'FR');
  var Codes := TCountries.Codes;
  WriteLn('Codes: [', string.Join(', ', Codes), ']');
end;

procedure TestTranslations;
var
  L: TArray<string>;
  T: TCountryTranslations;
begin
  L := TCountries.Locales;
  WriteLn('Available locales: [', string.Join(', ', L), ']');

  T := TCountries.Translations;
  Assert(T <> nil);
  Assert(T['FR'] = 'France');

  T := TCountries.Translations('fr-CA');
  Assert(T <> nil);
  Assert(T['FR'] = 'France');

  T := TCountries.Translations('00');
  Assert(T = nil);
end;

begin
  try
    SetConsoleOutputCP(CP_UTF8);
    TestBasic;
    TestFrance;
    TestEuropeRegion;
    TestTranslations;
    ReadLn;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
