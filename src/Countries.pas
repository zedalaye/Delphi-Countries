unit Countries;

{ /!\ This file must stay UTF-8 encoded /!\ }

{$include Countries.Locales.inc}

interface

uses
  Winapi.Windows,
  System.SysUtils,
  System.Character,
  System.Generics.Collections,
  Countries.Types;

type
  TCountry = class
  private
    { identification codes }
    FNumber: string;
    FAlpha2: string;
    FAlpha3: string;
    FGEC: string;                  // Geopolitical Entities and Codes - FIPS 10-4
    FIOC: string;                  // International Olympic Committee code
    FUnLocode: string;             // United Nations Location Code
    { names }
    FISOLongName: string;
    FISOShortName: string;
    FUnofficialNames: TArray<string>;
    { location & boundary box }
    FGeo: TCountryGeo;
    FContinent: string;
    FWorldRegion: string;
    FRegion: string;
    FSubRegion: string;
    { europe }
    FEEAMember: Boolean;
    FEUMember: Boolean;
    FG7Member: Boolean;
    FG20Member: Boolean;
    { telephone routing - E164 }
    FCountryCode: string;
    FNationalDestinationCodeLengthts: TArray<Integer>;
    FNationalNumberLengths: TArray<Integer>;
    FInternationalPrefix: string;
    FNationalPrefix: string;
    { country distance }
    FDistanceUnit: string;
    { currencies }
    FCurrencyCode: string;
    FVATRates: TArray<TCountryVATRate>;
    { addresses }
    FPostalCode: Boolean;
    FPostalCodeFormat: string;
    FAddressFormat: string;
    { geopolitical data }
    FNationality: string;
    FLanguagesOfficial: TArray<string>;
    FLanguagesSpoken: TArray<string>;
    FStartOfWeek: string;
    function GetGDPRCompliant: Boolean;
    function GetPostalCodeRegexp: string;
    function GetEmojiFlag: string;
    function GetCommonName: string;
    function GetTranslation(const Locale: string): string;
  public
    { identification codes }
    property Number: string read FNumber;
    property Alpha2: string read FAlpha2;
    property Alpha3: string read FAlpha3;
    property GEC: string read FGEC;
    property IOC: string read FIOC;
    property UnLocode: string read FUnLocode;
    { names }
    property ISOLongName: string read FISOLongName;
    property ISOShortName: string read FISOShortName;
    property UnofficialNames: TArray<string> read FUnofficialNames;
    property CommonName: string read GetCommonName;
    property Translation[const Locale: string]: string read GetTranslation;
    { location & boundary box }
    property Geo: TCountryGeo read FGeo;
    property Continent: string read FContinent;
    property WorldRegion: string read FWorldRegion;
    property Region: string read FRegion;
    property SubRegion: string read FSubRegion;
    { europe }
    property IsEEAMember: Boolean read FEEAMember;
    property IsEUMember: Boolean read FEUMember;
    property IsG7Member: Boolean read FG7Member;
    property IsG20Member: Boolean read FG20Member;
    { compliance }
    property GDPRCompliant: Boolean read GetGDPRCompliant;
    { telephone routing - E164 }
    property CountryCode: string read FCountryCode;
    property NationalDestinationCodeLengthts: TArray<Integer> read FNationalDestinationCodeLengthts;
    property NationalNumberLengths: TArray<Integer> read FNationalNumberLengths;
    property InternationalPrefix: string read FInternationalPrefix;
    property NationalPrefix: string read FNationalPrefix;
    { country distance }
    property DistanceUnit: string read FDistanceUnit;
    { currencies }
    property CurrencyCode: string read FCurrencyCode;
    property VATRates: TArray<TCountryVATRate> read FVATRates;
    { addresses }
    property HasPostalCode: Boolean read FPostalCode;
    property PostalCodeFormat: string read FPostalCodeFormat;
    property PostalCodeRegexp: string read GetPostalCodeRegexp;
    property AddressFormat: string read FAddressFormat;
    { geopolitical data }
    property Nationality: string read FNationality;
    property LanguagesOfficial: TArray<string> read FLanguagesOfficial;
    property LanguagesSpoken: TArray<string> read FLanguagesSpoken;
    property StartOfWeek: string read FStartOfWeek;
    property EmojiFlag: string read GetEmojiFlag;
  end;

  TCountryArray = TArray<TCountry>;

  TCountryName   = (cnAlpha2, cnAlpha3, cnCommonName, cnShortName, cnLongName, cnUnofficialName, cnAnyName);
  TCountryRegion = (crContinent, crWorldRegion, crRegion, crSubRegion);

  TCountryTranslations = TDictionary<string, string>;

  ECountryNameConflict = class(Exception);

  TCountries = record
  private
    type TCountryList  = TObjectList<TCountry>;
    type TNameCache    = TObjectDictionary<string, TCountry>;
    type TRegionCache  = TObjectDictionary<string, TCountryList>;
  private
    class var FDefaultLocale: string;
    class var FCountries: TCountryList; // owns values
    class var FNamesCache: array[TCountryName] of TNameCache;
    class var FRegionsCache: array[TCountryRegion] of TRegionCache;

    // LANG => { ALPHA2 => Name }
    class var FTranslations: TObjectDictionary<string, TCountryTranslations>;

    class constructor ClassCreate;
    class destructor ClassDestroy;

    class function BuildNameCache(Cache: TCountryName): TNameCache; static;
    class function GetNameCache(Cache: TCountryName): TNameCache; static;

    class function BuildRegionCache(Region: TCountryRegion): TRegionCache; static;
    class function GetRegionCache(Region: TCountryRegion): TRegionCache; static;
  public
    class function Get(const Alpha2: string): TCountry; static;
    class function Codes: TArray<string>; static;

    class function FindBy(NameIndex: TCountryName; const Name: string): TCountry; static;
    class function FindCountryByCommonName(const Name: string): TCountry; static;
    class function FindCountryByShortName(const Name: string): TCountry; static;
    class function FindCountryByLongName(const Name: string): TCountry; static;
    class function FindCountryByUnofficialName(const Name: string): TCountry; static;
    class function FindCountryByAnyName(const Name: string): TCountry; static;

    class function AllBy(RegionIndex: TCountryRegion; const Region: string): TCountryArray; static;
    class function AllByContinent(const ContinentName: string): TCountryArray; static;
    class function AllByWorldRegion(const WorldRegionName: string): TCountryArray; static;
    class function AllByRegion(const RegionName: string): TCountryArray; static;
    class function AllBySubRegion(const SubRegionName: string): TCountryArray; static;

    class function Locales: TArray<string>; static;
    class function Translations(const Locale: string = ''): TCountryTranslations; static;
    class property DefaultLocale: string read FDefaultLocale write FDefaultLocale;

    class property Countries: TCountryList read FCountries;
  end;

function CleanupString(const S: string): string;

implementation

{ Removes punctuation, symbols, whitespaces and accents (non spacing marks) and
  converts uppercased letters to lowercase }
function CleanupString(const S: string): string;
const
  DESIRABLE_UNICODE_CATEGORIES = [
//    TUnicodeCategory.ucControl,
//    TUnicodeCategory.ucFormat,
//    TUnicodeCategory.ucUnassigned,
//    TUnicodeCategory.ucPrivateUse,
//    TUnicodeCategory.ucSurrogate,
    TUnicodeCategory.ucLowercaseLetter,
    TUnicodeCategory.ucModifierLetter,
    TUnicodeCategory.ucOtherLetter,
    TUnicodeCategory.ucTitlecaseLetter,
    TUnicodeCategory.ucUppercaseLetter,
//    TUnicodeCategory.ucCombiningMark,
//    TUnicodeCategory.ucEnclosingMark,
//    TUnicodeCategory.ucNonSpacingMark,
    TUnicodeCategory.ucDecimalNumber,
    TUnicodeCategory.ucLetterNumber,
    TUnicodeCategory.ucOtherNumber
//    TUnicodeCategory.ucConnectPunctuation,
//    TUnicodeCategory.ucDashPunctuation,
//    TUnicodeCategory.ucClosePunctuation,
//    TUnicodeCategory.ucFinalPunctuation,
//    TUnicodeCategory.ucInitialPunctuation,
//    TUnicodeCategory.ucOtherPunctuation,
//    TUnicodeCategory.ucOpenPunctuation,
//    TUnicodeCategory.ucCurrencySymbol,
//    TUnicodeCategory.ucModifierSymbol,
//    TUnicodeCategory.ucMathSymbol,
//    TUnicodeCategory.ucOtherSymbol,
//    TUnicodeCategory.ucLineSeparator,
//    TUnicodeCategory.ucParagraphSeparator,
//    TUnicodeCategory.ucSpaceSeparator
  ];
var
  L: Integer;
  Tmp: string;
begin
  L := NormalizeString(NormalizationD, PChar(S), Length(S), nil, 0);
  SetLength(Tmp, L);

  L := NormalizeString(NormalizationD, PChar(S), Length(S), PChar(Tmp), Length(Tmp));
  SetLength(Tmp, L);

  Result := '';
  for var C in Tmp do
  begin
    if C.GetUnicodeCategory in DESIRABLE_UNICODE_CATEGORIES then
      if C.IsUpper then
        Result := Result + C.ToLower
      else
        Result := Result + C;
  end;
end;

{ TCountries }

class function TCountries.Get(const Alpha2: string): TCountry;
begin
  if not GetNameCache(cnAlpha2).TryGetValue(Alpha2, Result) then
    Result := nil;
end;

class function TCountries.Codes: TArray<string>;
begin
  Result := GetNameCache(cnAlpha2).Keys.ToArray;
end;

class function TCountries.FindBy(NameIndex: TCountryName;
  const Name: string): TCountry;
begin
  if not GetNameCache(NameIndex).TryGetValue(CleanupString(Name), Result) then
    Result := nil;
end;

class function TCountries.FindCountryByAnyName(const Name: string): TCountry;
begin
  Result := FindBy(cnAnyName, Name);
end;

class function TCountries.FindCountryByCommonName(const Name: string): TCountry;
begin
  Result := FindBy(cnCommonName, Name);
end;

class function TCountries.FindCountryByLongName(const Name: string): TCountry;
begin
  Result := FindBy(cnLongName, Name);
end;

class function TCountries.FindCountryByShortName(const Name: string): TCountry;
begin
  Result := FindBy(cnShortName, Name);
end;

class function TCountries.FindCountryByUnofficialName(
  const Name: string): TCountry;
begin
  Result := FindBy(cnUnofficialName, Name);
end;

class function TCountries.AllBy(RegionIndex: TCountryRegion;
  const Region: string): TCountryArray;
var
  L: TCountryList;
begin
  if not GetRegionCache(RegionIndex).TryGetValue(CleanupString(Region), L) then
    SetLength(Result, 0)
  else
    Result := L.ToArray;
end;

class function TCountries.AllByContinent(
  const ContinentName: string): TCountryArray;
begin
  Result := AllBy(crContinent, ContinentName);
end;

class function TCountries.AllByWorldRegion(
  const WorldRegionName: string): TCountryArray;
begin
  Result := AllBy(crWorldRegion, WorldRegionName);
end;

class function TCountries.AllByRegion(
  const RegionName: string): TCountryArray;
begin
  Result := AllBy(crRegion, RegionName);
end;

class function TCountries.AllBySubRegion(
  const SubRegionName: string): TCountryArray;
begin
  Result := AllBy(crSubRegion, SubRegionName);
end;

{ Translations }

class function TCountries.Locales: TArray<string>;
begin
  Result := FTranslations.Keys.ToArray;
end;

class function TCountries.Translations(
  const Locale: string): TCountryTranslations;
var
  Lang: string;
begin
  if Locale = '' then
    Lang := TCountries.FDefaultLocale
  else
    Lang := Locale;

  if not FTranslations.TryGetValue(Lang, Result) then
  begin
    var P := Pos('-', Lang);
    if P > 0 then
    begin
      Lang := Copy(Lang, 1, P -1);
      if not FTranslations.TryGetValue(Lang, Result) then
        Result := nil;
    end;
  end;
end;

{ Internal Plumbery }

class function TCountries.GetNameCache(Cache: TCountryName): TNameCache;
begin
  Result := FNamesCache[Cache];
  if Result = nil then
    Result := BuildNameCache(Cache);
end;

class function TCountries.GetRegionCache(Region: TCountryRegion): TRegionCache;
begin
  Result := FRegionsCache[Region];
  if Result = nil then
    Result := BuildRegionCache(Region);
end;

class function TCountries.BuildNameCache(Cache: TCountryName): TNameCache;

  procedure RegisterName(Cache: TNameCache; const Key: string; Country: TCountry);
  begin
  {$if defined(RELEASE)}
    Cache.AddOrSetValue(Key, Country);
  {$else}
    // in debug mode : verify that no names are pointing to two different countries
    var C: TCountry;
    if Cache.TryGetValue(Key, C) then
    begin
      if C <> Country then
        raise ECountryNameConflict.CreateFmt('Name "%s" conflicts between existing "%s" and "%s"', [Key, C.Alpha2, Country.Alpha2]);
    end
    else
      Cache.Add(Key, Country);
  {$endif}
  end;

begin
  Assert(FNamesCache[Cache] = nil);
  FNamesCache[Cache] := TNameCache.Create([]);
  Result := FNamesCache[Cache];

  for var C in FCountries do
  begin
    case Cache of
      cnAlpha2:
        RegisterName(Result, C.Alpha2, C);

      cnAlpha3:
        RegisterName(Result, C.Alpha3, C);

      cnCommonName:
        RegisterName(Result, CleanupString(C.CommonName), C);

      cnShortName:
        RegisterName(Result, CleanupString(C.ISOShortName), C);

      cnLongName:
        RegisterName(Result, CleanupString(C.ISOLongName), C);

      cnUnofficialName:
        for var UN in C.UnofficialNames do
          RegisterName(Result, CleanupString(UN), C);

      cnAnyName:
      begin
        RegisterName(Result, CleanupString(C.CommonName), C);
        RegisterName(Result, CleanupString(C.ISOShortName), C);
        RegisterName(Result, CleanupString(C.ISOLongName), C);
        for var UN in C.UnofficialNames do
          RegisterName(Result, CleanupString(UN), C);
      end;
    end;
  end;
end;

class function TCountries.BuildRegionCache(
  Region: TCountryRegion): TRegionCache;
begin
  Assert(FRegionsCache[Region] = nil);
  FRegionsCache[Region] := TRegionCache.Create([]);
  Result := FRegionsCache[Region];

  for var C in FCountries do
  begin
    var R: string;
    case Region of
      crContinent:   R := C.Continent;
      crWorldRegion: R := C.WorldRegion;
      crRegion:      R := C.Region;
      crSubRegion:   R := C.SubRegion;
    end;

    var L: TCountryList;
    if not Result.TryGetValue(CleanupString(R), L) then
    begin
      L := TCountryList.Create(False);
      Result.Add(CleanupString(R), L);
    end;
    L.Add(C);
  end;
end;

{ TCountry }

function TCountry.GetCommonName: string;
begin
  Result := Translation[''];
end;

function TCountry.GetTranslation(const Locale: string): string;
var
  Translations: TCountryTranslations;
begin
  Translations := TCountries.Translations(Locale);
  if (Translations = nil) or (not Translations.TryGetValue(FAlpha2, Result)) then
    Result := FISOShortName;
end;

function TCountry.GetEmojiFlag: string;
const
  BASE_CODE_POINT = $1f1e6 - Ord('A');
begin
  Result :=
    Char.ConvertFromUtf32(BASE_CODE_POINT + Ord(FAlpha2[1])) +
    Char.ConvertFromUtf32(BASE_CODE_POINT + Ord(FAlpha2[2]));
end;

function TCountry.GetGDPRCompliant: Boolean;
begin
  Result := FEEAMember or (FAlpha2 = 'GB');
end;

function TCountry.GetPostalCodeRegexp: string;
begin
  Result := '';
  if FPostalCode then
    Result := Format('\A%s\Z', [FPostalCodeFormat]);
end;

class destructor TCountries.ClassDestroy;
begin
  for var CR := Low(TCountryRegion) to High(TCountryRegion) do
    if FRegionsCache[CR] <> nil then
      FRegionsCache[CR].Free;

  for var CN := Low(TCountryName) to High(TCountryName) do
    if FNamesCache[CN] <> nil then
      FNamesCache[CN].Free;

  FTranslations.Free;
  FCountries.Free;
end;

class constructor TCountries.ClassCreate;

  procedure RegisterCountry(const Country: TCountry);
  begin
    FCountries.Add(Country);
  end;

  procedure RegisterTranslation(const Language, Alpha2, Value: string);
  var
    D: TDictionary<string, string>;
  begin
    if not FTranslations.TryGetValue(Language, D) then
    begin
      D := TCountryTranslations.Create;
      FTranslations.Add(Language, D);
    end;
    D.AddOrSetValue(Alpha2, Value);
  end;

begin
  FCountries := TCountryList.Create(True);
  FTranslations := TObjectDictionary<string, TCountryTranslations>.Create([doOwnsValues]);

  { Caches }
  for var CN := Low(TCountryName) to High(TCountryName) do
    FNamesCache[CN] := nil;
  for var CR := Low(TCountryRegion) to High(TCountryRegion) do
    FRegionsCache[CR] := nil;

  { Register Countries }
  {$include Countries.Data.inc}

  { Register Translations }
  {$include Countries.Translations.inc}
end;

end.
