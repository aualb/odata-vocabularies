# CodeList Vocabulary
**Namespace: [com.sap.vocabularies.CodeList.v1](CodeList.xml)**

Terms for Code Lists


## Terms

Term|Type|Description
:---|:---|:----------
[CurrencyCodes](CodeList.xml#L37)|[CodeListSource](#CodeListSource)|<a name="CurrencyCodes"></a>An entity set containing the code list for currencies
[UnitsOfMeasure](CodeList.xml#L41)|[CodeListSource](#CodeListSource)|<a name="UnitsOfMeasure"></a>An entity set containing the code list for units of measure
[StandardCode](CodeList.xml#L56) *([Experimental](Common.md#Experimental))*|PropertyPath|<a name="StandardCode"></a>Property containing standard code values
[ExternalCode](CodeList.xml#L61) *([Experimental](Common.md#Experimental))*|PropertyPath|<a name="ExternalCode"></a>Property containing code values that can be used for visualization<p>The annotated property contains values that are not intended for visualization and should thus stay hidden from end-users. Instead the values of the referenced properties are used for visualization.</p>
[IsConfigurationDeprecationCode](CodeList.xml#L68) *([Experimental](Common.md#Experimental))*|Boolean|<a name="IsConfigurationDeprecationCode"></a>Property contains a Configuration Deprecation Code<p>The Configuration Deprecation Code indicates whether a code list value is valid (deprecation code is empty/space), deprecated (deprecation code `W`), or revoked (deprecation code `E`).</p>

## <a name="CodeListSource"></a>[CodeListSource](CodeList.xml#L45)
An entity set containing the code list for currencies

Property|Type|Description
:-------|:---|:----------
[Url](CodeList.xml#L47)|URL|URL of a CSDL document describing an entity set for a code list
[CollectionPath](CodeList.xml#L51)|String|Name of the entity set for the code list