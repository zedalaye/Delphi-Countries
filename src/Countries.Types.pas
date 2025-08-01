unit Countries.Types;

interface

type
  TCountryVATRate = record
    Name: string;
    Rates: TArray<Currency>;
  end;

  TCountryGeoBounds = record
    Name: string;
    Lat: Double;
    Lng: Double;
  end;

  TCountryGeo = record
    Latitude: Double;
    Longitude: Double;
    MaxLatitude: Double;
    MaxLongitude: Double;
    MinLatitude: Double;
    MinLongitude: Double;
    Bounds: TArray<TCountryGeoBounds>;
  end;
  
implementation

end.
