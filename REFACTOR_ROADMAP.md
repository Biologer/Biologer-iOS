# Biologer iOS refactor roadmap

## Cilj

Cilj refaktora je da aplikacija na kraju:

- koristi jednu aktivnu implementaciju bez version flag-ova i V1/V2 sufiksa;
- koristi SwiftUI navigaciju i nove ekrane;
- bude organizovana po feature-ima i Clean Architecture slojevima;
- koristi novi `APIClient` sa bezbednim refresh-token mehanizmom;
- ne zavisi od legacy router-a, coordinator-a, servisa i UIKit navigacije;
- sačuva postojeće korisničke podatke;
- nema preostali kompatibilnosni sloj starog koda.

## Trenutno stanje — 5. avgust 2026.

Refaktor i fizičko brisanje legacy aplikacije su završeni.

| Oblast | Status |
| --- | --- |
| Authorization | SwiftUI flow koristi repositories i novi `APIClient`; nema UIKit coordinator-a ni version builder-a. |
| Main | `AppRootFlow` i `MainTabFlow` vode kompletnu SwiftUI navigaciju. |
| Findings | Lista, details, editor, altitude i upload koriste nove repository/APIClient tokove. |
| Settings/Session | Account, logout, delete account, profil i observation sync koriste use case/repository slojeve i `SessionStore`. |
| TaxonSync | Samostalan feature sa startup integracijom iz `AppRootFlow`-a. |
| Network | Svi aktivni endpoint-i koriste novi `APIClient`; refresh koordinira jedan in-flight zahtev i bezbedno obrađuje paralelne `401` odgovore. |
| Cleanup | Legacy router-i, coordinator-i, servisi, HTTP stack, UI, resursi, API error model, V1/V2 nazivi i compatibility alias-i su uklonjeni. |

Preostala razvojna stavka je Force Update preko Firebase Remote Config-a. Ona je namerno odložena dok se ne potvrde Firebase konfiguracija i release strategija. SwiftUI lifecycle prelazak je opcioni korak i nije uslov za završetak refaktora; jedan root `UIHostingController` u `SceneDelegate`-u ostaje nameran app-lifecycle adapter.

## Važna napomena za Firebase Force Update

Force Update ne treba ostaviti tek za poslednji objavljeni build.

Ako trenutna V1 aplikacija koju korisnici već imaju nema Firebase Remote Config kod, ona ne može naknadno da pročita Firebase vrednost. Firebase može blokirati samo verzije koje već sadrže taj mehanizam.

Postoje dve mogućnosti:

- Objaviti prelazni/bridge release koji još zadržava postojeću aplikaciju, ali već sadrži Force Update proveru. Parametar ostaje neaktivan dok finalni V2 ne stigne na App Store.
- Pošto aplikacija ima mali broj korisnika, obavestiti ih ručno da instaliraju novi V2. Force Update bi tada važio za sve kasnije verzije.

Za pouzdano serversko blokiranje svih starih buildova potreban je backend check.

## Originalni plan i arhitektonske odluke

Sledeće sekcije čuvaju originalni redosled migracije i razloge iza odluka. Statusna tabela iznad je merodavna za trenutno stanje projekta.

### 1. Završiti novi APIClient i Session infrastrukturu

Ovo treba da bude sledeća veća celina.

Potrebno je dodati:

- `RefreshTokenEndpoint`;
- request i response modele za refresh tokena;
- servis ili repository za refresh tokena;
- novi authenticated decorator koji:
  - dodaje trenutni access token;
  - prepoznaje `401`;
  - osvežava token;
  - čuva novi access i refresh token;
  - ponavlja originalni request samo jednom;
  - obaveštava aplikaciju kada refresh token više nije važeći.

Za paralelne zahteve treba koristiti jedan `actor`, na primer `TokenRefreshCoordinator`. Ako pet requestova istovremeno dobije `401`, treba poslati samo jedan refresh request, dok ostala četiri čekaju njegov rezultat.

Postojeći `TokenRefreshingHTTPClientDecorator` ne treba prekopirati. On čuva samo jedan zajednički `completion`, pa paralelni requestovi mogu prepisati callback jedni drugima.

Očekivani tok:

```text
401
 ↓
Da li je request već ponovljen?
 ├── Da → session expired
 └── Ne → jedan zajednički refresh
             ├── uspeh → ponovi request jednom
             ├── nema interneta → vrati network error, ne briši sesiju
             └── refresh odbijen → obriši sesiju i idi na Authorization
```

Pravila koja treba poštovati:

- Login, register i refresh endpoint ne koriste authenticated decorator.
- Originalni request može da se ponovi samo jednom, kako ne bi nastala beskonačna petlja.
- Network greška tokom refresh-a ne znači automatski da je session nevažeći.
- Tek odbijen ili nevažeći refresh token treba da izazove session expiration/logout.
- Token ne treba ispisivati u logovima.

### 2. Prebaciti preostale endpoint-e na novi APIClient

Migraciju treba raditi endpoint po endpoint, uz pregled koda i testove nakon svake celine.

Predloženi redosled:

1. `GetAltitudeEndpoint`
   - Mali i jednostavan primer kojim se proverava novi authenticated client.
   - Ukloniti zavisnost `FindingEditor` feature-a od starog `GetAltitudeService`.

2. Finding upload
   - `UploadFindingImageEndpoint`;
   - `UploadFindingEndpoint`;
   - novi request i response modeli;
   - novi repository adapteri;
   - uklanjanje `PostFindingService`, `PostFindingImageService` i legacy `TaxonImage` modela.

3. Account
   - `GetCurrentUserEndpoint`;
   - `DeleteAccountEndpoint`;
   - Account repository i use case;
   - logout/session use case.

4. Observation types
   - `ObservationTypesEndpoint`;
   - repository za lokalni Realm i remote dopunu;
   - use case za sinhronizaciju;
   - offline fallback na već sačuvane observation types.

5. Svi preostali pozivi koji se i dalje izvršavaju preko legacy `HTTPClient` interfejsa.

Tek kada je ovo završeno, novi feature-i više neće zavisiti od `Dashboard/Service` sloja.

### 3. Izdvojiti zajedničke modele iz pojedinačnih feature-a

Neki modeli se trenutno nalaze na mestima koja više nisu odgovarajuća:

- `Token` i `Environment` su u Authorization-u, iako ih koristi cela aplikacija;
- `User` i `Settings` su u `Common`;
- licence koriste Authorization, Settings i Findings;
- `TaxonImage` je legacy UI model koji trenutno koristi upload.

Predložena organizacija:

```text
Core/
├── Session/
│   ├── AuthToken
│   ├── SessionStore
│   └── TokenStorage
├── Environment/
│   ├── AppEnvironment
│   └── EnvironmentStorage
├── Persistence/
│   ├── Realm
│   ├── Keychain
│   └── UserDefaults
└── DesignSystem/
```

Realm objekti mogu ostati u Data/Persistence sloju. Clean Architecture ne znači uklanjanje Realm-a, Keychain-a, Google Maps-a ili UIKit wrapper-a; znači da Domain i Presentation ne treba direktno da zavise od njih.

### 4. Napraviti samostalni Account/Session deo

Settings trenutno šalje callback do `AppNavigationRouter`-a za:

- logout;
- delete account;
- otvaranje spoljašnjeg URL-a.

Logout i delete account treba zameniti odgovarajućim use case-ovima i zajedničkim `SessionStore`-om.

Na primer:

```swift
enum SessionState {
    case checking
    case unauthenticated
    case authenticated
}
```

Uspešan login postavlja `.authenticated`.

Logout, uspešno obrisan account ili odbijen refresh token postavljaju `.unauthenticated`.

Na taj način APIClient ne poznaje navigaciju, a root aplikacije samo reaguje na promenu session stanja.

### 5. Napraviti SwiftUI root aplikacije

Kada mreža i session budu spremni, treba napraviti:

```text
AppRootFlow
AppRootViewModel
AppCompositionRoot
```

Root stanje može izgledati ovako:

```swift
enum AppRootState {
    case launching
    case forceUpdate
    case authorization
    case preparingSession
    case taxonSync
    case main
}
```

Očekivani tok aplikacije:

```text
Launch
  ↓
Force Update provera
  ↓
Session provera
  ├── bez tokena → AuthorizationFlow
  └── ima token
        ↓
     profil + observation data
        ↓
     TaxonSync provera
        ↓
     MainTabFlow
```

`AppCompositionRoot` treba da zameni veliki composition deo iz `Common/AppNavigationRouter.swift`, ali ne treba da postane globalni service locator. Njegova odgovornost je da konstruiše zajedničku infrastrukturu i feature composition-e, a zatim eksplicitno prosledi njihove zavisnosti.

### 6. Ne menjati odmah app lifecycle

Najbezbedniji prelaz je:

1. Zadržati `AppDelegate` i `SceneDelegate`.
2. Postaviti jedan `UIHostingController(rootView: AppRootFlow(...))` kao root aplikacije.
3. Izbaciti `UINavigationController`, router-e i coordinator-e iz navigacije.
4. Tek kasnije, opciono, preći na SwiftUI lifecycle:

```swift
@main
struct BiologerApp: App
```

Jedan `UIHostingController` kao root omotač ne znači da navigacija nije SwiftUI. Google Maps i image picker mogu ostati implementirani preko `UIViewRepresentable` i `UIViewControllerRepresentable`.

### 7. Prebaciti startup odgovornosti iz AppNavigationRouter-a

`AppNavigationRouter` trenutno:

- pravi stari i novi network stack;
- upravlja tokenima;
- pokreće Authorization;
- učitava profil;
- učitava observation types;
- proverava i pokreće TaxonSync;
- prikazuje Main;
- radi logout;
- briše account;
- prikazuje UIKit alert-e.

Te odgovornosti treba raspodeliti na:

- `SessionStore`;
- `AppRootViewModel`;
- Account use case;
- Observation sync use case;
- TaxonSync composition;
- SwiftUI alert/dialog stanje odgovarajućih ViewModel-a.

Tada `AppNavigationRouter` više neće biti potreban.

### 8. Dodati Taxon catalog migration i Force Update

Kada root flow bude stabilan, treba dodati:

- Firebase Remote Config feature;
- `ForceUpdateFlow`;
- lokalnu `bundledTaxonCatalogVersion`;
- bezbednu zamenu CSV kataloga;
- odgovarajuću Realm/UserDefaults migraciju;
- App Store link;
- lokalizovane poruke.

Firebase Force Update i migracija Taxon kataloga treba da ostanu dve odvojene odluke:

- Firebase određuje koji build aplikacije je minimalno dozvoljen.
- Nova aplikacija poredi bundled catalog verziju sa lokalno instaliranom verzijom.

Prilikom migracije treba obezbediti da postojeći korisnici ne izgube:

- neuploadovane nalaze;
- slike;
- settings;
- izabrane licence;
- izabrani environment;
- session token, ako je i dalje važeći.

Ako se menjaju Realm modeli, potrebno je povećati `schemaVersion` i napisati eksplicitnu Realm migraciju.

## V2-only cutover pre brisanja

Prebacivanje root-a i brisanje legacy koda ne treba raditi u istom koraku.

Preporučeni proces:

1. Ukloniti `AuthorizationUIVersion` i `MainUIVersion` grananje.
2. Podesiti da aplikacija uvek pokreće samo novi `AppRootFlow`.
3. Privremeno ostaviti legacy kod u projektu, ali bez aktivne putanje do njega.
4. Uraditi build, sve testove i kompletnu ručnu proveru.
5. Poslati V2-only build na TestFlight.
6. Tek nakon uspešne provere početi fizičko brisanje legacy koda.

Na taj način je V1 ponašanje i dalje dostupno za poređenje ako se tokom V2-only provere pronađe funkcionalnost koja nedostaje.

## Redosled brisanja legacy koda

### 1. Authorization

Obrisati kada Authorization više ne zavisi od UIKit composition-a:

- `AuthorizationRouter`;
- `AuthorizationCoordinatorBuilder`;
- `AuthorizationFlowCoordinator`;
- `Presentation/UI/V1`;
- `Data/Legacy`;
- stare view-controller factory-je;
- `AuthorizationUIVersion`.

### 2. Main navigacija

Obrisati nakon što `AppRootFlow` direktno prikazuje `MainTabFlow`:

- `LegacyMainCoordinator`;
- `MainCoordinatorBuilder`;
- `MainTabCoordinator`;
- `MainUIVersion`;
- Side Menu router i UI;
- `TaxonRouter`;
- `DownloadTaxonRouter`.

### 3. Dashboard

Nakon migracije svih funkcionalnosti obrisati:

- stare UI ekrane;
- stare ViewModel-e;
- router-e;
- ViewControllerFactory-je;
- legacy servise;
- stare mapper-e i modele koji više nemaju potrošače.

Ne treba obrisati ceo `Dashboard` folder odjednom dok god novi feature-i koriste neki tip iz njega.

### 4. Legacy Network

Kada nijedan aktivan feature više ne koristi stari network stack, obrisati:

- `HTTPClient`;
- `URLSessionHTTPClient`;
- `APIRequest`;
- `Auth2HttpClientDecorator`;
- `TokenRefreshingHTTPClientDecorator`;
- `GetTokenService`;
- `CodableParser`;
- legacy `APIError`, kada više nema potrošača.

### 5. Završni cleanup

- ukloniti SideMenu package;
- ukloniti neupotrebljene asset-e;
- ukloniti stare lokalizacione ključeve;
- ukloniti ili migrirati stare testove;
- premestiti preostalu zajedničku infrastrukturu iz `Common` i `Storage` u odgovarajuće `Core` celine;
- preimenovati `LoginScreenV2` u `LoginScreen`, `FindingEditorV2ViewModel` u `FindingEditorViewModel` i slično;
- ukloniti `V1`, `V2` i version flag terminologiju iz finalnog koda.

V2 trenutno još koristi stare lokalizacione ključeve poput `SideMenu.lb.listOfFindings` i `NewTaxon...`. Ti ključevi ne smeju biti obrisani dok se njihove V2 reference ne preimenuju.

## Testovi i provera ponašanja

Za svaku veću celinu preporučeni proces je:

1. implementacija;
2. pregled koda i arhitekture;
3. potrebne izmene;
4. testovi;
5. smislen commit;
6. prelazak na sledeću celinu.

Pre finalnog brisanja V1 obavezno proveriti:

- cold launch bez tokena;
- cold launch sa važećim tokenom;
- cold launch sa isteklim access tokenom;
- više paralelnih requestova koji dobiju `401`;
- uspešan refresh;
- odbijen refresh i povratak na Authorization;
- privremeni gubitak interneta tokom refresh-a;
- login i registration u svim environment-ima;
- logout;
- delete account sa obe opcije;
- postojeće i novo kreiranje nalaza;
- edit nalaza;
- upload jednog i više nalaza;
- delimično neuspešan upload i ponovni pokušaj;
- image upload;
- altitude i Google Maps;
- Taxon CSV import i API dopuna;
- pause/resume TaxonSync-a;
- prazan, delimičan i kompletan Taxon catalog;
- Settings, licence, Help i About;
- očuvanje postojećih Realm, UserDefaults i Keychain podataka.

## Uslovi za bezbedno brisanje V1

V1 se može obrisati tek kada važi sve sledeće:

- nijedan V2 builder ne prima legacy servis;
- svi remote pozivi koriste novi `APIClient`;
- refresh token radi bezbedno i sa više paralelnih `401` odgovora;
- logout i expired session vraćaju SwiftUI root na Authorization;
- profil i observation types više ne pokreće router;
- TaxonSync startup radi iz `AppRootFlow`;
- `MainTabFlow` i `AuthorizationFlow` se prikazuju bez UIKit coordinator-a;
- postojeći Realm/UserDefaults/Keychain podaci ostaju kompatibilni;
- nema aktivnih referenci na V1 router-e, factory-je, servise i ViewModel-e;
- build i svi testovi prolaze;
- TestFlight verzija prolazi kompletan funkcionalni scenario.

Pre fizičkog brisanja treba pretražiti projekat i potvrditi da nema referenci na ključne legacy tipove:

```text
AuthorizationUIVersion
MainUIVersion
AuthorizationRouter
LegacyMainCoordinator
SideMenuRouterRouter
TaxonRouter
DownloadTaxonRouter
HTTPClient
APIRequest
TokenRefreshingHTTPClientDecorator
```

## Predloženi commit redosled za finalni cutover

Finalno uklanjanje je bolje podeliti na više smislenih commitova:

1. `refactor(app): switch composition to v2 only`
2. `remove(authorization): delete legacy authorization flow`
3. `remove(main): delete legacy coordinators and side menu`
4. `remove(network): delete legacy http stack and services`
5. `chore(project): remove unused assets strings and dependencies`
6. `refactor(naming): remove v2 suffixes from production types`

## Sledeći konkretan korak

Sledeća razvojna celina je Force Update, kada Firebase Remote Config i release strategija budu potvrđeni.

Pre produkcionog release-a ostaju ručna regresiona provera scenarija iz sekcije „Testovi i provera ponašanja“ i TestFlight validacija očuvanja postojećih Realm, UserDefaults i Keychain podataka.
