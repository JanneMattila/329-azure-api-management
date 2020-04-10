# 329-azure-api-management


## Sales Api

```powershell
dotnet run create --configFile sales.api.yml
```

## Export existing APIM

```powershell
dotnet run extract --extractorConfig extractorparams.json
```

`extractorparams.json`:

```json
{
  "sourceApimName": "apim-source",
  "destinationApimName": "apim-destination",
  "resourceGroup": "rg-name",
  "fileFolder": "c:\\temp\\apim_extract"
}
```
