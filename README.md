# Countries

Countries is a Delphi port of the [Countries RubyGem](https://github.com/countries/countries) which is a collection of all sorts of useful information for every country in the ISO 3166 standard. It contains info for the following standards ISO3166-1 (countries), ISO4217 (currency) and E.164 (phone numbers).

Subdivision (ISO3166-2) data have not been ported, nor currencies data (which requires the [Money RubyGem](https://github.com/RubyMoney/money)) and full translations support.

The data used come from [Countries JSON](https://github.com/countries/countries-data-json) files.

## Basic Usage

Simply load a new country object using `TCountries.Get(*alpha2*)` An example works best.

```delphi
var C = TCountries.Get('FR');
```

Get all country codes (*alpha2*).

```delphi
var Codes := TCountries.Codes;
//  ["TJ", "JM", "HT",...]
```

## Attribute-Based Finder Methods

You can lookup a country or an array of countries using any of the data attributes via the `FindBy*` methods:

```delphi
var I    := TCountries.FindByShortName('italy');
var U    := TCountries.FindByAnyName('united states');
var List := TCountries.AllByRegion('Americas')
var F    := TCountries.FindBy(cnAlpha2, 'FR');
```

Note: searches are *case insensitive and ignore accents*.

## Localisation

The `generate` tool converts Countries data and translations to .inc files, by default, only french (`fr`) translations are embedded into the runtime code.

To add more locales to the runtime, edit the `src\Countries.Locales.inc` file and activate all required locales. You can activate all available locales by defining `LANG_ALL`, either in `src\Countries.Locales.inc` or project wize using the Delphi Project Options dialog.

```delphi
// Activate or deactivate languages as needed
// Ensure that the default language defined in Countries.Translations.inc is active.

// Shortcut: Activate this one to embed all available translations. May be set project wise in your .dproj
{.$define LANG_ALL}

{.$define LANG_ab}
{.$define LANG_af}
...
{$define LANG_fr}
...
{$define LANG_it}
...
```

To change the default locale, edit the `src\Countries.Translations.inc` file and change the `DefaultLocale` property :

```delphi
// TCountries.DefaultLanguage property defines how TCountry.CommonName behaves
TCountries.DefaultLocale := 'en'; // generator default is 'fr'
...
```

## Country Info

### Identification Codes

```delphi
C.Number   // => "840"
C.Alpha2   // => "US"
C.Alpha3   // => "USA"
C.GEC      // => "US"  (Geopolitical Entities and Codes aka FIPS 10-4)
C.IOC      // => "USA" (International Olympic Committee)
C.UnLocode // => "US"  (United Nations Location Code)
```

### Names & Translations

```delphi
C.ISOLongName     // => "The United States of America"
C.ISOShortName    // => "United States of America"
C.CommonName      // => "United States"
C.UnofficialNames // => ["United States of America", "Vereinigte Staaten von Amerika", "États-Unis", "Estados Unidos"]

// Get a specific translation
C.Translation['de']; // => 'Vereinigte Staaten von Amerika'

// Get all translations for a locale, defaults to `TCountry.DefaultLocale`
TCountries.Translations;       // => {"DE"=>"Germany",...} 
TCountries.Translations('de'); // => {"DE"=>"Deutschland",...}

// List all activated locales
TCountries.Locales; // => ['fr', 'en', 'de', ...]

// Nationality
C.Nationality // => "American"
```

### Location

```delphi
C.Latitude // => "37.09024"
C.Longitude // => "-95.712891"

C.WorldRegion // => "AMER"
C.Region // => "Americas"
C.SubRegion // => "Northern America"
```

### Telephone Routing (E164)

```delphi
C.CountryCode // => "1"
C.NationalDestinationCodeLengths // => [3]
C.NationalNumberLengths // => 10
C.InternationalPrefix // => "011"
C.NationalPrefix // => "1"
```

### Boundary Boxes

```delphi
C.MinLongitude // => '45'
C.MinLatitude // => '22.166667'
C.MaxLongitude // => '58'
C.MaxLatitude // => '26.133333'

C.Bounds // => [ (Name: "northeast", Lat: 22.166667, Lng: 58), (Name: "southwest", Lat: 26.133333, Lng: 45) ]
```

### European Union Membership

```delphi
C.EUMember // => false
```

### European Economic Area Membership

```delphi
C.EEAMember // => false
```

<!---
### European Single Market Membership

```delphi
C.ESMMember // => false
```
--->

<!---
### EU VAT Area membership

```ruby
c.in_eu_vat? # => false
```
--->

### GDPR Compliant (European Economic Area Membership or UK)

```delphi
C.GDPRCompliant // => false
```

### Country Code in Emoji

```delphi
var C = TCountries.Get('MY');
C.EmojiFlag // => "🇲🇾"
```

### Country Distance Unit (miles/kilometres)

```delphi
C.DistanceUnit # => "MI"
```

## Address Formatting

A template for formatting addresses is available through the `AddressFormat` method. These templates are compatible with the [Liquid](https://shopify.github.io/liquid/) template system.

```delphi
C.AddressFormat // => "{{recipient}}\n{{street}}\n{{city}} {{region}} {{postalcode}}\n{{country}}"
```

## Note on Patches/Pull Requests

**Please do not submit pull requests on `src/Countries.Data.inc`**. This file is generated by the `generate` program and is not meant to be manually updated.

If you wish to submit a PR to update or correct country data, please submit issues the [Countries RubyGem](https://github.com/countries/countries) project.

## Copyright

The copyright for the original code is retained to the authors and contributors of the [Countries RubyGem](https://github.com/countries/countries) project and its dependencies.

Copyright for the Delphi code is ©Pierre Yager and is ditributed using the same LICENCES terms as the original [Countries RubyGem](https://github.com/countries/countries) project.
