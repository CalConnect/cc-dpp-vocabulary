# ISO Form 4 — New Work Item Proposal

> Filling text for "Form 4 — New Work Item Proposal", V01/2025 edition,
> modelled on the CalConnect 2018 NWIP for ISO/TC 154 (which became
> ISO 34000:2023, _Date and time — Vocabulary_). Submit to the
> ISO/IEC JTC 5 secretariat (DIN, Committee Manager Amelie Buss) with
> a copy to the ISO Central Secretariat. The proposer is CalConnect
> acting in its capacity as a Category A liaison organization of
> ISO/IEC JTC 5.

---

**Circulation date:** 2026-09-07

**Closing date for voting:** [set by ISO/CS on receipt]

**Reference number:** [to be given by ISO Central Secretariat]

**Proposer (ISO member body or A liaison organization):**
CalConnect (Category A liaison of ISO/IEC JTC 5)

**Committee:** ISO/IEC JTC 5, _Digital product passport_
(secretariat DIN, committee manager Amelie Buss,
chair Adrian von Mühlenen).

☒ The proposer has considered the guidance given in
Annex C of the ISO/IEC Directives, Part 1, during the preparation of
the NWIP.

---

## Proposal (to be completed by the proposer)

### Title of the proposed deliverable

**CalConnect document number:** 93333  
**Form:** vocabulary (ISO `:docsubtype: vocabulary`)

**English title:** Digital product passport — Part 1: Vocabulary

**French title:** Passeport numérique de produit — Partie 1: Vocabulaire

### Scope of the proposed deliverable

This document establishes the vocabulary for the digital product
passport (DPP).

It defines terms for the fundamental concepts of the digital product
passport as used in the documents that currently govern or inform its
implementation, and harmonises those concepts where their definitions
conflict across the source corpus. The source corpus comprises the
EN 182xx series (EN 18216:2026, EN 18219:2026, EN 18220:2026,
EN 18221:2026, EN 18222:2026, EN 18223:2026, EN 18239:2026,
EN 18246:2026), CWA 18291:2025, the Asset Administration Shell
metamodel specification IDTA 01001-3.2:2026, ISO/AWI 25534-1
(revision of 2026-09-05), and the further ISO, IEC and UN standards
cited as sources of individual definitions.

The harmonised vocabulary contains approximately 80 to 120 term
entries in the core clauses (3.1 to 3.7), drawn from the 145-concept
verified machine-readable dataset published at
https://glossarist.org/dpp/ (mirror: https://unidpp.org/terminology/).
The proposed standard supports the division of ISO 25534-1 into a
Part 1 (Vocabulary) and a Part 2 (Overview and fundamental
principles) and is intended to serve all subsequent parts of ISO
25534 and documents referring to them.

### Purpose and justification of the proposal

*Verified market need.* The DPP vocabulary is required by every
stakeholder implementing, regulating or auditing the European
Ecodesign for Sustainable Products Regulation (Regulation (EU) 2024/1781,
ESPR), the European Health Data Space, and the corresponding
international initiatives of the United Nations Economic Commission for
Europe (UNECE Transparency Protocol) and of the World Trade
Organization (WTO Technical Barriers to Trade). The 145-concept
verified dataset (https://glossarist.org/dpp/, mirror
https://unidpp.org/terminology/) records that eight published
European Standards (EN 18216:2026 to EN 18223:2026, EN 18239:2026,
EN 18246:2026) and the working draft ISO/AWI 25534-1 (2026-09-05)
carry mutually incompatible definitions of the same fundamental
concepts — the digital product passport itself, the unique
identifier, the economic operator, interoperability — and that these
definitions are not harmonised by any current or proposed document.

*Problem solved.* Two systems of definitions for the DPP are being
developed in parallel, and they do not cite each other normatively.
The eight EN 182xx standards (CEN-CLC/JTC 24 under the European
Commission's standardisation request M/604) define the DPP as a
"digital record of product characteristics throughout its life
cycle"; the working draft ISO/AWI 25534-1 (ISO/IEC JTC 5) defines it
as "a concept or technology which enables sharing of product related
information". The core noun — a record on the one hand, a concept or
technology on the other — is normatively incompatible between the
two systems that are required to interoperate. The full-text
comparison of the corpus also records casing drift between
implementations of the same field (`lastUpdated` in EN 18223 against
`lastUpdate` in IDTA 02099-1), three unreconciled lifecycle
taxonomies inside the EN series itself, three lookup systems
(resolver, registry API and the central EU registry) whose
relationships are never specified, and role models that are never
mapped to the API-level authorisation that would enforce them.

*Value to end-users.* A common vocabulary is the prerequisite for
machine-readable conformance verification, for inter-jurisdictional
passport interoperability, and for the semantic definition repository
that EN 18223:2026 requires but does not specify. The vocabulary is
the foundation on which the proposed ISO 25534-1 Part 2 (Overview
and fundamental principles) and the planned Part 3 (Data model)
depend.

### Preparatory work

☒ A draft is attached (working draft, PWI stage 00.00, dated
2026-09-07, in the sources/iso-93333/ directory of the
drafting workspace, compiled from the machine-readable concept
dataset published at https://glossarist.org/dpp/ and the mirror
https://unidpp.org/terminology/).

The proposer or the proposer's organization is prepared to undertake
the preparatory work required: ☒ Yes.

If a draft is attached to this proposal:

☐ Draft document will be registered as new project in the
committee's work programme (stage 20.00).
☒ Draft document can be registered as a Working Draft
(WD — stage 20.20).
☐ Draft document can be registered as a Committee Draft
(CD — stage 30.00).
☐ Draft document can be registered as a Draft International Standard
(DIS — stage 40.00).

☒ If the attached document is copyrighted or includes copyrighted
content, the proposer confirms that copyright permission has been
granted for ISO to use this content in compliance with clause 2.13
of the ISO/IEC Directives, Part 1.

Is this a Management Systems Standard (MSS)? ☐ Yes ☒ No.

### Indication(s) of the preferred type or types of deliverable(s)

☒ International Standard.
☐ Technical Specification.
☐ Publicly Available Specification.
☐ Technical Report.

### Proposed development track

☒ 18 months.
☐ 24 months.
☐ 36 months.
☐ 48 months.

### Draft project plan

* Proposed date for first meeting: 2026-12 (Berlin or virtual).
* Dates for key milestones:
 * DIS submission: 2027-09.
 * Publication: 2028-03.

### Known patented items

☐ Yes ☒ No.

### Coordination of work

To the best of your knowledge, has this or a similar proposal been
submitted to another standards development organization?

☐ Yes ☒ No.

### Relationship to existing work

This proposal supports the division of the accepted work item
ISO/AWI 25534-1 into a Part 1 (Vocabulary) and a Part 2 (Overview
and fundamental principles), as proposed by SAC at the first plenary
of ISO/IEC JTC 5 (Berlin, 2026-09-07–09, agenda item 13, document
N49). It is complementary to the EN 182xx series (CEN-CLC/JTC 24)
and to the Asset Administration Shell metamodel (IDTA 01001-3.2),
with which it harmonises rather than competes. It builds upon and
is intended to be used in conjunction with:

* ISO/IEC 15459, _Information technology — Automatic identification
 and data capture techniques — Unique identification_, in particular
 Part 1 (transport units), Part 2 (registration procedures),
 Part 3 (common rules) and Part 6 (groupings);
* ISO/IEC 18975, _Information technology — Automatic identification
 and data capture techniques — Encoding and resolving identifiers
 over HTTP_;
* ISO/IEC 22123-1, _Information technology — Cloud computing —
 Part 1: Terminology_;
* ISO/IEC 17000, _Conformity assessment — Vocabulary and general
 principles_;
* ISO/IEC 20248, _Information technology — Automatic identification
 and data capture techniques — Digital signature data structure
 schema_;
* ISO 59004, _Circular economy — Vocabulary, principles and guidance
 for implementation_;
* ISO 59040, _Circular economy — Product circularity data sheet_;
* ISO 22095, _Chain of custody — General terms and models_;
* ISO 14040, _Environmental management — Life cycle assessment —
 Principles and framework_;
* ISO 8601-1, _Date and time — Representation for information
 interchange — Part 1: Basic rules_;
* ISO 80000-3, _Quantities and units — Part 3: Space and time_;
* ISO 5157, _Textiles — Environmental aspects — Vocabulary_;
* the UN Transparency Protocol (UNTP), the UNCEFACT Traceability
 and Transparency BRS, and the Product Circularity Data Use Case
 BRS;
* the UNECE Recommendation No. 46, _Enhancing traceability and
 transparency of sustainable value chains in the garment and
 footwear sector_.

### A listing of relevant existing documents

International:

* ISO/AWI 25534-1, _Digital product passport — Part 1: Overview and
 fundamental principles_, working draft (2026-09-05).
* ISO/TC 307 series (blockchain and distributed ledger technologies),
 in particular ISO 22739 (vocabulary) and ISO 23257 (reference
 architecture), as the structural template for derivative
 DPP standards.
* IEC 63278-1, _Industrial-process measurement, control and
 automation — Asset administration shell for industrial applications
 — Part 1: Concept_.
* IDTA 01001-3.2:2026, _Specification of the Asset Administration
 Shell — Part 1: Metamodel_.
* ISO/IEC 15459 (all parts), _Unique identification_.
* ISO/IEC 18975:2024, _Encoding and resolving identifiers over HTTP_.
* ISO/IEC 22123-1:2023, _Cloud computing — Part 1: Terminology_.
* ISO/IEC 17000:2020, _Conformity assessment — Vocabulary and general
 principles_.
* ISO/IEC 20248:2022, _Digital signature data structure schema_.
* ISO 59004:2024, _Circular economy — Vocabulary, principles and
 guidance for implementation_.
* ISO 59040, _Circular economy — Product circularity data sheet_.
* ISO 22095:2020, _Chain of custody — General terms and models_.
* ISO 14040:2006, _Environmental management — Life cycle assessment —
 Principles and framework_.
* ISO 8601-1:2019, _Date and time — Representation for information
 interchange — Part 1: Basic rules_.
* ISO 80000-3, _Quantities and units — Part 3: Space and time_.
* ISO 5157:2023, _Textiles — Environmental aspects — Vocabulary_.
* UNECE Recommendation No. 46, _Enhancing traceability and
 transparency of sustainable value chains in the garment and
 footwear sector_.
* UN Transparency Protocol (UNTP), UN/CEFACT, development draft.

Regional:

* EN 18216:2026, _Digital Product Passport — Data exchange
 protocols_.
* EN 18219:2026, _Digital Product Passport — Unique identifiers_.
* EN 18220:2026, _Digital product passport — Data carriers_.
* EN 18221:2026, _Digital Product Passport — Data storage, archiving,
 and data persistence_.
* EN 18222:2026, _Digital Product Passport — Application Programming
 Interfaces (APIs) for the product passport lifecycle management
 and searchability_.
* EN 18223:2026, _Digital Product Passport — System interoperability_.
* EN 18239:2026, _Digital Product Passport — Access rights
 management, information system security, and business
 confidentiality_.
* EN 18246:2026, _Digital product passport — Data authentication,
 reliability and integrity_.
* CWA 18291:2025, _TRICK — Guidelines on data collection from Textile
 supply chains for the Digital Product Passport_.

### Benefits/impacts on stakeholder categories

[cols="2,3,3",options="header"]
|===
| Stakeholder category | Benefits/impacts | Examples of organizations to be contacted

| Industry and commerce — large industry | Common DPP vocabulary enabling inter-vendor interoperability; conformance testing against a single normative source; reduced cost of multi-jurisdictional product compliance. | Manufacturers of electronics, batteries, textiles, iron and steel, aluminium, construction products, furniture, tyres, mattresses, packaging, and information and communication technology products placed on the EU market under ESPR delegated acts.
| Industry and commerce — SMEs | Reduced entry cost for compliance; access to a single normative vocabulary that is the input to conformance tools and to semantic definition repositories. | Small and medium manufacturers of textiles, footwear, furniture, packaging and consumer electronics.
| Government | Harmonised vocabulary for delegated acts and implementing acts under ESPR; alignment of EU registry, national DPP implementations and third-country passports. | European Commission (DG ENV, DG GROW), national authorities responsible for market surveillance, customs authorities.
| Consumers | Interoperable passports across product categories and jurisdictions; reliable access to compliance, sustainability and provenance information. | Consumer associations, repair and recycling networks.
| Labour | Common vocabulary for repair, refurbishment and recycling sectors; alignment with ILO conventions on just transition. | Labour unions in the textile, electronics and construction sectors.
| Academic and research bodies | Reproducible machine-readable concept dataset for empirical research on DPP interoperability and conformance; harmonised basis for the UNTP-aligned semantic definition repository. | Universities with industrial engineering, industrial ecology and information systems programmes; UNECE; OECD.
| Standards application businesses | Single source of truth for DPP conformance testing and certification; reduced cost of maintaining multiple vocabulary maps. | Certification bodies, conformance testing laboratories, accreditation bodies.
| Non-governmental organizations | Common vocabulary for environmental and social claims verification; alignment with the OECD Due Diligence Guidance and with the UN Guiding Principles on Business and Human Rights. | NGOs active in sustainable value chains, transparency initiatives and consumer protection.
|===

### Liaisons to be engaged in the development of the deliverable

* ISO/TC 154, _Processes, data elements and documents in commerce,
 industry and administration_ (CalConnect's parent TC; ISO 34000
 authorship; UNTDED stewardship);
* ISO/TC 307, _Blockchain and distributed ledger technologies_ (the
 structural template for derivative DPP standards);
* ISO/TC 323, _Circular economy_ (ISO 59004, ISO 59040 authorship);
* ISO/IEC JTC 1/SC 27, _Information security, cybersecurity and
 privacy protection_ (trust semantics);
* ISO/IEC JTC 1/SC 31, _Automatic identification and data capture
 techniques_ (ISO/IEC 15459 family authorship);
* CEN-CLC/JTC 24, _Digital Product Passport_ (EN 182xx series);
* Industrial Digital Twin Association (IDTA) (Asset Administration
 Shell specification);
* UN/CEFACT (UN Transparency Protocol);
* UNECE (UNECE Recommendation No. 46);
* CalConnect (Calendaring and Scheduling Consortium; proposing
 organization);
* OIML (International Organization of Legal Metrology; OIML SMART
 programme);
* ELF (Express Logic Forum; EXPRESS and OWL formal models).

### Joint/parallel work

☐ IEC (please specify committee ID): none proposed.
☒ Other: CEN-CLC/JTC 24 (parallel work under the EC standardisation
request M/604 + Amd1); UN/CEFACT (parallel work on the UN Transparency
Protocol).

### Countries which are not already P-members of the committee

[to be completed by the committee secretary on receipt]

### Proposed Project Leader

CalConnect secretariat (secretariat@calconnect.org), with the ISO/TC
154 liaison representative as alternate.

### Name of the Proposer

CalConnect — The Calendaring and Scheduling Consortium.
Postal address: [CalConnect secretariat address].
Website: https://www.calconnect.org.
Contact: secretariat@calconnect.org.

### This proposal will be developed by

☐ An existing Working Group (please specify which one).
☒ A new Working Group (title: WG 2, _Vocabulary_, if established
under the WS B _Basics_ structure proposed in N34 of the first
ISO/IEC JTC 5 plenary).
☐ The TC/SC directly.
☐ To be determined.

### Supplementary information

☒ This proposal relates to a new ISO document.
☐ This proposal relates to the adoption as an active project of an
item currently registered as a Preliminary Work Item.
☐ This proposal relates to the re-establishment of a cancelled
project as an active project.

☐ This proposal requires the service of a maintenance agency.
☐ This proposal requires the service of a registration authority.

☒ Annex(es) are included with this proposal:
* Annex A — _Audit of the UniDPP DPP concept dataset_, in
 the companion dataset audit report
 (companion audit report identifying the duplicate-designation
 findings, the international-source gaps and the resolution
 precedents, including the resolution of the dpp-0001 / dpp-0004
 merger of 2026-09-07).
* Annex B — _Digital product passport — Part 1: Vocabulary_
 working draft (CalConnect 93333 / ISO PWI stage 00.00), the PWI stage 00.00 draft
 attached as the source-of-truth deliverable for the proposed
 Part 1.

### Maintenance agencies and registration authorities

None required.

### Signature

* I am aware of the responsibilities and obligations of proposer
 organizations per ISO/IEC Directives, Part 1, Clause 1.17. ☒
* **Name:** [authorized signatory, CalConnect secretariat]
* **Date:** [date]
