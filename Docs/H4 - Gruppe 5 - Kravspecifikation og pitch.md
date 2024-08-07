## Kravspecifikation, udvikling af gruppe 4s produkt

### Projekt Pitch

Vi vil udvikle en lokal turismeapp for SKSBooking. Vores mål er at skabe en applikation, der kan finde lokale tilbud og lejemål, ved at integrere funktionalitet, der udnytter data indsamlet fra telefonens sensorer.

For at opnå dette, tænker vi at anvende Flutter, .NET og PostgreSQL til henholdsvis applikation, API og database, og benytte os af progammeringssprogene Dart og C\# til at bygge app’en samt API. App’en vil kunne bruge GPS data til at finde lokale interessepunkter og støtte lokale samarbejdspartnere via geodata derfra i forhold til, hvor kunden befinder sig.

Vores applikation vil have følgende funktioner:

* **Brugeroprettelse:** Brugerne skal kunne oprette profiler med profilbillede, fulde navn, telefonnummer og e-mailadresse. Derudover skal administratorer være i stand til at sende invitationer ud til partnere og udlejere, der giver dem adgang til udlejerkonti og reklameringsprivilegier.  
    
* **Sensorintegration:** App’en vil bruge GPS for at finde ud af, hvor kunden befinder sig, og derfra finde nærliggende tilbud og lejeboliger.  
    
* **Booking:** Lejere skal være i stand til at finde og leje lejeboliger, samt finde kontaktinformation på udlejere for at gøre processen nemmere.  
    
* **Oprette og redigere lejeboligopslag:** Udlejere skal have mulighed for at oprette og publicere lejeboliger med adresse, beskrivelse, pris, mm. Derudover skal de kunne uploade et galleri af billeder af disse boliger fra deres telefon.  
    
* **(Push-)Notifikationer:** Udlejere skal underrettes om priser i deres område for en given periode eller sæson.

Kunden vil blive involveret i projektarbejdet med regelmæssige møder for at sikre, at vi opfylder deres behov og forventninger. Vi vil også overveje at integrere ekstra funktioner som et bedømmelse/anmeldelsessystem, partnerannoncer, integration med sociale medier, AI-integration med fokus på analyse af pristrends, og geotagging af billeder, afhængig af projektets fremdrift og tidsplan.

Dette projekt vil give os praktisk erfaring med mobiludvikling, brug af GPS, Flutter og SCRUM processen \+ roller, og give os mulighed for at udforske, hvordan teknologi kan anvendes til at løse reelle problemer eller forbedre dagligdagen.

### 

### Om

SKSBooking er et nyopstartet firma i turistindustrien med hovedsæde i Budapest. De efterspørger en løsning, der tilbyder deres kunder at finde lokale tilbud og lejemål i form af en mobilapp, for at fremme lokale samarbejdspartnere og gøre det nemmere for kunder at benytte deres service. Mobilappen skal bruge geolokation/GPS for at give de bedst mulige lokale tilbud til den individuelle kunde, afhængigt af lokation.

### Krav

**Produkt:**

* Produktet skal udvikles som en mobilapp  
* Produktet skal have et brugerinterface  
* Produktet skal have en tilknyttet database  
* Produktet skal have brugerregistrering og brugerhåndtering

**Brugere:**

* Brugere skal være i stand til at indsætte et profilbillede, mail og tlfnr  
* Brugere skal være i stand til at ændre deres loginoplysninger  
* Lejere skal være i stand til at kontakte udlejere og booke boliger  
* Lejere skal være i stand til at bruge geolokation til at finde restauranter, lejeboliger og andre attraktioner i valgfri radius omkring lokation  
* Lejere skal være i stand til at søge på lejeboliger efter ledighed i valgt tidsrum  
* Udlejere skal være i stand til at indtaste lejeboliger og redigere dem  
* Udlejere skal kunne tilmelde sig notifikationer omkring prisniveauet for lejeboliger i området for en given periode  
* Administratorer skal være i stand til at ændre eller slette vilkårlig information  
* Administratorer skal være i stand til at invitere til at lave udlejerkonti

**Lejeboliger:**

* Lejeboliger skal have tilgængeligt galleri, beskrivelse, pris, adresse og geolokation samt mail og tlfnr på udlejer. Ledighed og ledighedsperiode skal være synlig  
* Information vedr. lejeboliger skal kunne skjules over for ikke-brugere  
* Hvem der har lejet en bolig og hvornår skal gemmes og kunne vises til relevant udlejer

#### Ekstra/nice to have:

* Brugerbedømmelser  
* One-click reklamering til udlejere på sociale medier  
* AI-integration mht at udregne pristrends til udlejere  
* Administrator kan oprette annoncer fra vores samarbejdspartnere så vi har reklameindtægter gennem vores app  
* Geolokation/geotagging og validering på billeder af lejeboliger

#### 

#### Spørgsmål til kunde

**Q: Skal udlejere selv kunne oprette sig eller skal admin oprette udlejere?**  
A: Admin giver invitation/token til udlejere

**Q: Skal annonce bruger være nice to have eller krav, da den står begge steder**  
A: Nice to have

**Q: Hvem er brugeren til annonce krav-ikke-kravet \- admin eller ekstern?**  
A: Admin

**Q: Der nævnes restauranter, events etc. i opgaveteksten. Men kun 1 sted i krav omkring geo lokation. Ville der ikke være behov for noget mere, når der er fokus på promovering af Budapest?**  
A: Ville være nice (to have)