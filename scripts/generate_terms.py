#!/usr/bin/env python3
"""Generate Metanorma term-entry sections for the DPP vocabulary working draft.

Sources of truth:
  - Glossarist UniDPP dataset: (local dataset path via env) (146 concepts)
  - Framework vocabulary drafted from the UniDPP design framework (terminology blocks + prose)
    and /the UniDPP operator model (end-list candidates)

Output: sources/iso-25534-1-pwi/sections/03-*.adoc + build_stats.json
"""

import glob
import json
import os
import re
import sys

import yaml

DATASET = os.path.expanduser("(local dataset path via env)")
OUTDIR = os.path.expanduser(
    "(local dataset path via env)"
)

# ---------------------------------------------------------------------------
# Bibliography anchors: dataset ref string -> anchor
# ---------------------------------------------------------------------------
REF_MAP = {
    "EN 18223:2026": "EN18223",
    "EN 18239 (prEN 18239:2025)": "EN18239",
    "EN 18216:2026": "EN18216",
    "EN 18221:2026": "EN18221",
    "EN 18222:2026": "EN18222",
    "EN 18246 (prEN 18246:2025)": "EN18246",
    "EN 18220:2026": "EN18220",
    "EN 18219:2026": "EN18219",
    "CWA 18291:2025": "CWA18291",
    "ISO/AWI 25534-1 (2026-09-05 draft)": "AWI25534",
    "IDTA-01001-3.2:2026 (Specification of the Asset Administration Shell — Part 1: Metamodel)": "IDTA01001",
    "IEC 63278-1:2023": "IEC63278",
    "ISO 59004:2024": "ISO59004",
    "UNECE Recommendation No. 46": "UNECE46",
    "ISO 5157:2023": "ISO5157",
    "IEC TR 62390:2005-01": "IECTR62390",
    "ISO 29404:2015": "ISO29404",
    "ISO/IEC 27031": "ISOIEC27031",
    "ECLASS": "ECLASS",
    "ISO 24619:2011": "ISO24619",
    "EN ISO/IEC 24760-1": "ISOIEC24760",
    "ISO/IEC 6523-1": "ISOIEC6523",
    "ISO/IEC 19762": "ISOIEC19762",
    "ISO 23234:2021": "ISO23234",
    "EN ISO 14025:2010": "ISO14025EN",
    "ISO 14025:2006": "ISO14025",
    "ISO 9000": "ISO9000",
    "ISO/TS 24533:2012": "ISOTS24533",
    "ISO 24533-2:2022": "ISO24533-2",
    "ISO 14040:2006": "ISO14040",
    "ISO/IEC/IEEE 8802-1AR": "IEEE8802-1AR",
    "ISO 7498-2:1989": "ISO7498-2",
    "ISO/IEC 29180:2012": "ISOIEC29180",
    "EN ISO/IEC 27000": "ISOIEC27000",
    "ISO/IEC 17000:2020": "ISOIEC17000",
    "ISO/IEC Guide 2:2004": "ISOIECGuide2",
    "IEC TS 62443-1-1": "IECTS62443",
    "ISO/IEC 22123-1:2023": "ISOIEC22123",
    "ISO 18435-1:2009": "ISO18435",
    "ISO 18308:2011": "ISO18308",
    "ISO 15531-43": "ISO15531",
    "IIC Vocabulary IIC:IIVOC:V2.3:20201025": "IICVOC",
    "Glossary Industrie 4.0": "I40GLOSS",
    "ISO/IEC 10746-2": "ISOIEC10746",
    "IEC 61499-1": "IEC61499",
    "ISO 22095:2020": "ISO22095",
    # components of compound refs
    "ISO/IEC Guide 77-2": "ISOIECGuide77",
    "IEC 61360-1:2016": "IEC61360",
    "ISO 22274:2013": "ISO22274",
    "IEC 60050-741:2020": "IEV741",
    "IEC 61666:2010+AMD1:2021 CSV": "IEC61666",
    "IEC 62569-1": "IEC62569",
    # ref strings that embed a clause
    "IEC 62890:2016": "IEC62890",
}

# Components recorded in the dataset that cannot be resolved to a real
# document (evident typos in the dataset) are dropped and reported.
DROPPED_COMPONENTS = {"ISO/IEC 27460"}

BIBLIO = {
    "EN18216": '[[[EN18216,EN 18216:2026]]], _Digital Product Passport — Data exchange protocols_',
    "EN18219": '[[[EN18219,EN 18219:2026]]], _Digital Product Passport — Unique identifiers_',
    "EN18220": '[[[EN18220,EN 18220:2026]]], _Digital product passport — Data carriers_',
    "EN18221": '[[[EN18221,EN 18221:2026]]], _Digital Product Passport — Data storage, archiving, and data persistence_',
    "EN18222": '[[[EN18222,EN 18222:2026]]], _Digital Product Passport — Application Programming Interfaces (APIs) for the product passport lifecycle management and searchability_',
    "EN18223": '[[[EN18223,EN 18223:2026]]], _Digital Product Passport — System interoperability_',
    "EN18239": '[[[EN18239,EN 18239:2026]]], _Digital Product Passport — Access rights management, information system security, and business confidentiality_ (citations verified against the prEN 18239:2025 enquiry draft)',
    "EN18246": '[[[EN18246,EN 18246:2026]]], _Digital product passport — Data authentication, reliability and integrity_ (citations verified against the prEN 18246:2025 enquiry draft)',
    "CWA18291": '[[[CWA18291,CWA 18291:2025]]], _TRICK — Guidelines on data collection from Textile supply chains for the Digital Product Passport_',
    "AWI25534": '[[[AWI25534,ISO/AWI 25534-1]]], _Digital product passport — Part 1: Overview and fundamental principles_, working draft of 2026-09-05, ISO/IEC JTC 5',
    "IDTA01001": '[[[IDTA01001,IDTA 01001-3.2:2026]]], _Specification of the Asset Administration Shell — Part 1: Metamodel_, Industrial Digital Twin Association',
    "IEC63278": '[[[IEC63278,IEC 63278-1:2023]]], _Industrial-process measurement, control and automation — Asset administration shell for industrial applications — Part 1: Concept_',
    "ISO59004": '[[[ISO59004,ISO 59004:2024]]], _Circular economy — Vocabulary, principles and guidance for implementation_',
    "UNECE46": '[[[UNECE46,UNECE Recommendation No. 46]]], _Enhancing traceability and transparency of sustainable value chains in the garment and footwear sector_, United Nations Economic Commission for Europe',
    "ISO5157": '[[[ISO5157,ISO 5157:2023]]], _Textiles — Environmental aspects — Vocabulary_',
    "IECTR62390": '[[[IECTR62390,IEC TR 62390:2005]]], _Common automation device — Profile guideline_',
    "ISO29404": '[[[ISO29404,ISO 29404:2015]]], _Ships and marine technology — Offshore wind energy — Supply chain information flow_',
    "ISOIEC27031": '[[[ISOIEC27031,ISO/IEC 27031]]], _Information technology — Security techniques — Guidelines for information and communication technology readiness for business continuity_',
    "ECLASS": '[[[ECLASS,ECLASS]]], _ECLASS — the reference data standard for the classification and description of products and services_, ECLASS e.V., current release',
    "ISO24619": '[[[ISO24619,ISO 24619:2011]]], _Language resource management — Persistent identification and sustainable access (LIRI)_',
    "ISOIEC24760": '[[[ISOIEC24760,ISO/IEC 24760-1]]], _Information technology — Security techniques — A framework for identity management — Part 1: Terminology and concepts_',
    "ISOIEC6523": '[[[ISOIEC6523,ISO/IEC 6523-1]]], _Information technology — Structure for the identification of organizations and organization parts — Part 1: Identification of organization identification schemes_',
    "ISOIEC19762": '[[[ISOIEC19762,ISO/IEC 19762 (all parts)]]], _Information technology — Automatic identification and data capture (AIDC) techniques — Harmonized vocabulary_',
    "ISO23234": '[[[ISO23234,ISO 23234:2021]]], _Buildings and civil engineering works — Security — Planning of security measures in the built environment_',
    "ISO14025EN": '[[[ISO14025EN,EN ISO 14025:2010]]], _Environmental labels and declarations — Type III environmental declarations — Principles and procedures_',
    "ISO14025": '[[[ISO14025,ISO 14025:2006]]], _Environmental labels and declarations — Type III environmental declarations — Principles and procedures_',
    "ISO9000": '[[[ISO9000,ISO 9000:2015]]], _Quality management systems — Fundamentals and vocabulary_',
    "ISOTS24533": '[[[ISOTS24533,ISO/TS 24533:2012]]], _Intelligent transport systems — Electronic information exchange to facilitate the movement of freight and its intermodal transfer — Road transport information exchange_',
    "ISO24533-2": '[[[ISO24533-2,ISO 24533-2:2022]]], _Intelligent transport systems — Electronic information exchange to facilitate the movement of freight and its intermodal transfer — Part 2: Common reporting system methodology_',
    "ISO14040": '[[[ISO14040,ISO 14040:2006]]], _Environmental management — Life cycle assessment — Principles and framework_',
    "IEEE8802-1AR": '[[[IEEE8802-1AR,ISO/IEC/IEEE 8802-1AR]]], _Telecommunications and information exchange between information systems — Local and metropolitan area networks — Specific requirements — Part 1AR: Secure device identity_',
    "ISO7498-2": '[[[ISO7498-2,ISO 7498-2:1989]]], _Information processing systems — Open Systems Interconnection — Basic Reference Model — Part 2: Security Architecture_',
    "ISOIEC29180": '[[[ISOIEC29180,ISO/IEC 29180:2012]]], _Information technology — Telecommunications and information exchange between systems — Security framework for ubiquitous sensor networks (USN)_',
    "ISOIEC27000": '[[[ISOIEC27000,ISO/IEC 27000]]], _Information technology — Security techniques — Information security management systems — Overview and vocabulary_',
    "ISOIEC17000": '[[[ISOIEC17000,ISO/IEC 17000:2020]]], _Conformity assessment — Vocabulary and general principles_',
    "ISOIECGuide2": '[[[ISOIECGuide2,ISO/IEC Guide 2:2004]]], _Standardization and related activities — General vocabulary_',
    "IECTS62443": '[[[IECTS62443,IEC TS 62443-1-1]]], _Industrial communication networks — Network and system security — Part 1-1: Terminology, concepts and models_',
    "ISOIEC22123": '[[[ISOIEC22123,ISO/IEC 22123-1:2023]]], _Information technology — Cloud computing — Part 1: Terminology_',
    "ISO18435": '[[[ISO18435,ISO 18435-1:2009]]], _Industrial automation systems and integration — Diagnostics, capability assessment and maintenance applications integration — Part 1: Overview and general requirements_',
    "ISO18308": '[[[ISO18308,ISO 18308:2011]]], _Health informatics — Requirements for an electronic health record architecture_',
    "ISO15531": '[[[ISO15531,ISO 15531-43]]], _Industrial automation systems and integration — Industrial manufacturing management data — Part 43: Manufacturing flow management data: Data model for flow monitoring and manufacturing data exchange_',
    "IICVOC": '[[[IICVOC,Industrial Internet Vocabulary]]], _Industrial Internet Vocabulary_, version V2.3 (IIC:IIVOC:V2.3:20201025), Industrial Internet Consortium',
    "I40GLOSS": '[[[I40GLOSS,Glossar Industrie 4.0]]], _Glossar Industrie 4.0_ [Industrie 4.0 glossary], German Industrie 4.0 community glossary, current release',
    "ISOIEC10746": '[[[ISOIEC10746,ISO/IEC 10746-2]]], _Information technology — Open Distributed Processing — Reference Model: Foundations_',
    "IEC61499": '[[[IEC61499,IEC 61499-1]]], _Function blocks — Part 1: Architecture_',
    "ISO22095": '[[[ISO22095,ISO 22095:2020]]], _Chain of custody — General terms and models_',
    "ISOIECGuide77": '[[[ISOIECGuide77,ISO/IEC Guide 77-2:2008]]], _Guide for specification of product properties and classes — Part 2: Technical principles and guidance_',
    "IEC61360": '[[[IEC61360,IEC 61360-1:2016]]], _Standard data element types with associated classification scheme — Part 1: Definitions — Principles and methods_',
    "ISO22274": '[[[ISO22274,ISO 22274:2013]]], _Systems to manage terminology, knowledge and content — Concept relations and their internationalization_',
    "IEV741": '[[[IEV741,IEC 60050-741:2020]]], _International Electrotechnical Vocabulary — Part 741: Digital twin_',
    "IEC61666": '[[[IEC61666,IEC 61666:2010+AMD1:2021 CSV]]], _Industrial systems, installations and equipment and industrial products — Identification of terminals within a system_',
    "IEC62569": '[[[IEC62569,IEC 62569-1:2017]]], _Generic specification of information on products by properties — Part 1: Principles and methods_',
    "IEC62890": '[[[IEC62890,IEC 62890:2016]]], _Life-cycle management for systems and products used in industrial-process measurement, control and automation_',
}

PRIORITY = {
    "authoritative": 0,
    "authoritatives-equivalent": 1,
    "adopted": 2,
    "adapted": 3,
    "lineage": 4,
    "conflicting": 5,
    "proposed": 6,
}

cited_anchors = set()
dropped_notes = []


def esc(text):
    """Light AsciiDoc escaping for paragraph text coming from the dataset."""
    out_lines = []
    for ln in text.split("\n"):
        s = ln.lstrip()
        if s and s[0] in ".-*+=[:>!|_`<":
            ln = "\\" + ln
        ln = ln.replace("{", "\\{")
        out_lines.append(ln)
    return "\n".join(out_lines)


def parse_ref(raw):
    """Return (anchor, clause, display) or None; handles compound components
    and refs that embed a clause."""
    raw = raw.strip()
    if raw in REF_MAP:
        return (REF_MAP[raw], None)
    # refs like "IEC 62890:2016, 3.1.16 65/617/CDV" or "IEC 61360-1:2016, 3.1.8"
    m = re.match(r"^(.*?),\s*(\d+(?:\.\d+)*)\b(.*)$", raw)
    if m and m.group(1).strip() in REF_MAP:
        return (REF_MAP[m.group(1).strip()], m.group(2))
    return None


def cite(anchor, clause):
    cited_anchors.add(anchor)
    if clause:
        return f'<<{anchor},clause="{clause}">>'
    return f"<<{anchor}>"


def split_compound(raw):
    if ";" not in raw:
        return [raw.strip()]
    parts = [p.strip() for p in raw.split(";") if p.strip()]
    return parts


def render_source_block(sources):
    """Render the [.source] block for a concept's source list."""
    if not sources:
        return None
    ordered = sorted(
        sources, key=lambda s: PRIORITY.get(s.get("type", "authoritative"), 9)
    )
    primary = ordered[0]
    pieces = []
    # remaining sources
    for s in ordered[1:]:
        stype = s.get("type", "authoritative")
        raw = s["origin"]["ref"]
        clause = s["origin"].get("clause") or ""
        mod = (s.get("modification") or "").strip()
        comps = [parse_ref(c) for c in split_compound(raw)]
        comps = [c for c in comps if c]
        if not comps:
            dropped_notes.append(raw)
            continue
        c = cite(comps[0][0], clause or comps[0][1])
        for extra in comps[1:]:
            c += " and " + cite(extra[0], extra[1])
        if stype == "authoritatives-equivalent":
            piece = f"an equivalent definition is given in {c}"
        elif stype == "authoritative":
            piece = f"the concept is also defined in {c}"
        elif stype == "adopted":
            piece = f"the definition is adopted from {c}"
        elif stype == "adapted":
            piece = f"the definition is adapted from {c}"
        elif stype == "lineage":
            piece = f"lineage: {c}"
        elif stype == "conflicting":
            piece = f"a conflicting definition is recorded in {c}"
        else:
            piece = f"see also {c}"
        if mod:
            piece += f": {mod}"
        pieces.append(piece)
    # primary
    praw = primary["origin"]["ref"]
    pclause = primary["origin"].get("clause") or ""
    pmod = (primary.get("modification") or "").strip()
    pcomps = [parse_ref(c) for c in split_compound(praw)]
    pcomps = [c for c in pcomps if c]
    if not pcomps:
        dropped_notes.append(praw)
        return None
    pc = cite(pcomps[0][0], pclause or pcomps[0][1])
    tail = ""
    ptype = primary.get("type", "authoritative")
    if pmod:
        if ptype == "authoritative":
            tail = f", modified — {pmod}"
        else:
            tail = f", {pmod}"
    if pieces:
        tail = (tail + "; " if tail else ", ") + "; ".join(pieces)
    elif not tail:
        tail = ""
    return f"[.source]\n{pc}{tail}"


def render_term(d, anchor):
    """Render one concept as a Metanorma term entry."""
    lines = []
    terms = d.get("terms", [])
    expr_pref = None
    alts = []
    for t in terms:
        if t.get("type") == "expression" and t.get("normative_status") == "preferred" and expr_pref is None:
            expr_pref = t["designation"]
        else:
            alts.append(t["designation"])
    if expr_pref is None:
        # preferred designation is an abbreviation
        for t in terms:
            if t.get("normative_status") == "preferred":
                expr_pref = t["designation"]
                break
        alts = [a for a in alts if a != expr_pref]
    heading = expr_pref if expr_pref else d["term"]
    lines.append(f"[[{anchor}]]")
    lines.append(f"=== {heading}")
    for a in alts:
        lines.append(f"alt:[{a}]")
    lines.append("")
    lines.append(esc(d["definition"].strip()))
    lines.append("")
    for n in d.get("notes", []) or []:
        n = n.strip()
        nl = n.split("\n")
        first = "NOTE: " + esc(nl[0])
        rest = ["  " + esc(x) for x in nl[1:]]
        lines.append("\n".join([first] + rest))
        lines.append("")
    for ex in d.get("examples", []) or []:
        lines.append("[example]")
        lines.append("--")
        lines.append(esc(ex.strip()))
        lines.append("--")
        lines.append("")
    sb = render_source_block(d.get("sources", []))
    if sb:
        lines.append(sb)
        lines.append("")
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# Load concepts
# ---------------------------------------------------------------------------
concepts = {}
for f in sorted(glob.glob(os.path.join(DATASET, "concept-*.yaml"))):
    d = yaml.safe_load(open(f))
    concepts[d["termid"]] = d

# ---------------------------------------------------------------------------
# Clause layout
# ---------------------------------------------------------------------------
SOURCED_CLAUSES = [
    ("03-1-dpp.adoc",
     "[heading=terms and definitions]\n== Terms related to the digital product passport",
     "digital-product-passport"),
    ("03-2-identity.adoc",
     "== Terms related to identity and carriers",
     "identity-and-carriers"),
    ("03-3-actors.adoc",
     "== Terms related to actors and issuance",
     "actors-and-issuance"),
    ("03-4-lifecycle.adoc",
     "== Terms related to lifecycle and events",
     "lifecycle-and-events"),
    ("03-5-trust.adoc",
     "== Terms related to trust and verification",
     "trust-and-verification"),
    ("03-6-semantics.adoc",
     "== Terms related to semantics and profiles",
     "semantics-and-profiles"),
    ("03-7-measurement.adoc",
     "== Terms related to measurement and material flow",
     "measurement"),
]

FW_UMBRELLA = (
    "NOTE: The terms in 3.8 to 3.16 are defined in this working draft for the "
    "UniDPP framework architecture described in the Introduction. They carry no "
    "external source: they name concepts of the projection, provenance, tier and "
    "trust model for which the analysed corpus (Annex A) provides no term. They "
    "are candidates for evaluation by ISO/IEC JTC 5 and are expected to be "
    "confirmed, reworded or replaced as the framework work proceeds. Concepts "
    "dpp-0124 to dpp-0146 are taken from the verified machine-readable concept "
    "dataset; the remaining framework entries are drafted from the framework "
    "design documentation for this working draft."
)

# Framework entries: (heading-anchor, termid or new-entry dict)
FRAMEWORK_CLAUSES = [
    ("03-8-fw-profiles.adoc",
     "== Framework terms — profiles, lenses and jurisdiction", [
        "dpp-0124", "dpp-0127",
        {"term": "lens mount",
         "definition": "standardized interface of the neutral core through which any registered profile is attached to and operates on the record of the subject, such that profiles from any registering authority compose without proprietary binding",
         "notes": ["The mount, not any single profile technology, is the interoperation point; standardizing it precludes lock-in to a proprietary profile mechanism."]},
        {"term": "jurisdiction profile",
         "definition": "profile that binds the data points, transforms, cryptographic suites, trust requirements, access rules, presentation and carrier requirements enacted by the law of a given jurisdiction",
         "notes": ["Conflicting regional rules are registered as distinct data elements harmonized to a common concept; they are not merged."]},
        {"term": "sector overlay",
         "definition": "profile that composes with other profiles to add the data points, transforms and rules applicable to an industry sector, such as electronics, textiles, batteries, construction, tyres or packaging"},
        {"term": "applicable law",
         "definition": "totality of legal rules that apply to a subject placed on a market, represented in the passport system by the corresponding jurisdiction profile and its dated applicability bindings"},
        {"term": "as-of query",
         "definition": "query against the event-sourced record of a subject that reconstructs the state that was legally valid at a specified past time",
         "notes": ["As-of queries are answered from notarized snapshots, log anchoring and recorded profile-version bindings, for example to establish whether a product was compliant when sold."]},
        {"term": "trust list",
         "definition": "signed, registry-deposited list of the trust anchors accredited to act under a given profile or jurisdiction, served with status and revocation information",
         "notes": ["Jurisdictional trust lists relate to one another through a multi-witnessed master list."]},
    ]),
    ("03-9-fw-projection.adoc",
     "== Framework terms — projection, composition and service tiers", [
        "dpp-0126",
        {"term": "materialized view",
         "definition": "rendered, citable result of a projection, materialized at a point in time for serving and verification",
         "notes": ["The digital product passport is the legal materialized view of the digital twin."]},
        {"term": "child passport",
         "definition": "passport of a component or sub-product that is independently placed on the market or independently regulated, referenced by identity from the passport of the composite product",
         "notes": ["Children join by identity reference, never by data copying; roll-up views are computed from the references."]},
        {"term": "containment event",
         "definition": "typed event recording that one passport is physically or structurally contained in another, retained for genealogy and recall traversal and never transferring authority"},
        {"term": "genealogy",
         "definition": "complete directed ancestry of a passport, traced through transformation and containment events from raw-material and component passports to the present subject"},
        "dpp-0146",
        {"term": "offline minimum",
         "definition": "subset of passport data and verification material specified as sufficient for offline verification of identity and status from the data carrier alone",
         "notes": ["The Tier-A payload is the carrier-embedded realization of the offline minimum."]},
        {"term": "degradation ladder",
         "definition": "ordered set of service tiers by which availability and verification degrade explicitly, from the served full passport through the carrier-embedded minimum to the archival record",
         "notes": ["Stale or offline data is always marked as such, never silently passed as current."]},
        "dpp-0131",
        {"term": "Tier-B payload",
         "definition": "full passport content, served through resolution and hosting services in accordance with the applicable profile"},
        {"term": "Tier-C archive",
         "definition": "notarized archival form of the passport record, retained for persistence beyond the operational lifetime of any single provider"},
    ]),
    ("03-10-fw-lattice.adoc",
     "== Framework terms — provenance, identity lattice and edge segments", [
        {"term": "provenance class",
         "definition": "declared category of a fact according to how it entered the record: declared at type level, measured at instance level under a stated method and uncertainty, or computed by a stated transform"},
        {"term": "precedence rule",
         "definition": "rule declared by a profile stating which provenance class prevails when facts about the same subject disagree",
         "notes": ["The default precedence is instance-measured over type-declared; a genuine same-class contradiction is an integrity incident, never a silent merge."]},
        {"term": "roll-up attestation",
         "definition": "signed attestation giving an aggregate over a committed traversal set of child passports, verifiable without fetching every member of the set"},
        {"term": "traversal set",
         "definition": "committed, hash-identified set of passport versions over which a roll-up attestation or a graph traversal is computed"},
        {"term": "edge segment",
         "definition": "part of the event-sourced record of a subject that originates on the subject's own device and is published through device commitments",
         "notes": ["The device is a tier of the passport system, not a client; it commits now and reveals later, but never contradicts."]},
        {"term": "device commitment",
         "definition": "signature by a device-bound key over the hash of a prefix of the device's local append-only event log, published so that later disclosures are inclusion-consistent with past commitments"},
        {"term": "configuration vector",
         "definition": "exact combination of registered component options that, together with a model, constitutes a configured product instance"},
        {"term": "type version",
         "definition": "versioned state of a type passport capturing hardware revisions and type-declared facts, referenced exactly by the instance passports derived from it"},
        {"term": "derived type",
         "definition": "new type resulting from a regulated modification of an existing type, recorded as a derivation event in the identity lattice"},
        "dpp-0135",
        {"term": "dormant-to-live adoption",
         "definition": "act of a future passport regime of issuing passports by adopting the identifiers already recorded as dormant for the object class, rather than minting new ones",
         "notes": ["Adoption connects the installed base retroactively through its build records; minting fresh identifiers would orphan it."]},
    ]),
    ("03-11-fw-stamps.adoc",
     "== Framework terms — stamps and the transformation algebra", [
        "dpp-0128",
        {"term": "lens-scoped attestation",
         "definition": "attestation whose validity is defined by, and only by, the profile under which it was issued",
         "notes": ["A stamp is the signed form of a lens-scoped attestation."]},
        "dpp-0130",
        "dpp-0129",
        {"term": "inputReference",
         "definition": "record in the issuance event of a derived passport naming an input passport, the quantity consumed and the as-of state hash under which it was taken",
         "notes": ["The new passport hash-links its sources, so that the provenance graph is reconstructable without trusting the issuing actor alone."]},
        {"term": "quantity carve-out",
         "definition": "recorded allocation of input quantity to an output of a split transformation, such that the sum of the child quantities does not exceed the parent"},
        {"term": "mass balance accounting",
         "definition": "bookkeeping over transformation events in which inputs and outputs of a specified characteristic are reconciled per period, with losses and taint carried explicitly",
         "notes": ["Mass balance accounting applies a mass balance model (3.7.1) to a set of transformation events."]},
        {"term": "consumed passport",
         "definition": "input passport that has reached the consumed or transformed state in a transformation event, retaining historical verifiability for as-of queries"},
        {"term": "blind provenance",
         "definition": "attestation of input provenance issued by a notified or accredited body that withholds the raw input identities behind its own attestation, used where commercial confidentiality demands it"},
        {"term": "jurisdiction stamp",
         "alt": ["visa"],
         "definition": "stamp issued under a jurisdiction profile on a passport issued under another jurisdiction, recording that the stamping jurisdiction's requirements were assessed",
         "notes": ["“Visa” is the colloquial designation of a jurisdiction stamp on a foreign-issued passport; entry and exit stamps are the verifier's custody events."]},
    ]),
    ("03-12-fw-characteristic.adoc",
     "== Framework terms — characteristic profiles and orphan objects", [
        "dpp-0125",
        "dpp-0141",
        {"term": "commissioning",
         "definition": "issuance act by which a qualified attestor or registrar establishes the identity of an object that predates or lies outside a manufacturer-issued regime, recording the first sighting in the event log"},
        {"term": "qualified attestor",
         "definition": "actor accredited under a profile's trust list to commission identities or to attest attributes of orphan objects, such as an auction house, authentication board or registrar"},
        {"term": "attribution",
         "definition": "expert statement assigning an object to a creator, workshop or period, recorded as a competing fact with provenance rather than merged with other attributions"},
        {"term": "provenance gap",
         "definition": "explicitly recorded interval in a subject's custody or provenance chain for which no evidence exists",
         "notes": ["A provenance gap is data, not an error; it is honestly representable in the event-sourced record."]},
        {"term": "condition report",
         "definition": "dated, signed, profile-scoped assessment of the physical condition of an object"},
        {"term": "restitution flag",
         "definition": "authority-attached marker on a passport recording a claim over title, such as looting, dispossession or colonial taking, propagated as a graph event without rewriting history"},
    ]),
    ("03-13-fw-capability.adoc",
     "== Framework terms — capability classes and digital twins", [
        {"term": "capability class",
         "definition": "classification of a subject by its ability to participate in its own record: silent, passive-auth, logged-contact or connected",
         "notes": ["A profile's freshness and verification requirements shall be satisfiable by the capability class of the subject; demanding live freshness from a silent subject is an unsatisfiable profile."]},
        {"term": "silent subject",
         "alt": ["capability class S0"],
         "definition": "subject with no connectivity, keys or self-reporting, whose record is reconstructed entirely from testimonies about it"},
        {"term": "passive-auth subject",
         "alt": ["capability class S1"],
         "definition": "subject carrying an authentication element, such as an NFC chip, physically unclonable function or identity link, that attests identity without recording events"},
        {"term": "logged-contact subject",
         "alt": ["capability class S2"],
         "definition": "subject that records events locally and discloses them on physical contact, without communications capability"},
        {"term": "connected subject",
         "alt": ["capability class S3"],
         "definition": "subject that self-reports under device keys and participates with full edge segments"},
        "dpp-0132",
        "dpp-0133",
        "dpp-0145",
        {"term": "service-center model",
         "definition": "arrangement in which a subject's state is sampled and attested only when the subject visits an attestor, yielding episodic truth and unbounded, undetectable staleness between attestations"},
        {"term": "self-testimony",
         "definition": "testimony class consisting of events asserted by the subject's own device under device-bound keys"},
        {"term": "continuous conformity monitoring",
         "definition": "conformity mode in which requirements are re-judged against the live state of the twin, rather than only at point-in-time inspection"},
        {"term": "state of health",
         "definition": "derived verdict on the condition of a subject, computed by a stated model from measured variables",
         "notes": ["The provenance of the computing model is itself governed information; health status is not a raw fact."]},
        {"term": "sensor attestation",
         "definition": "attestation binding a measured value to a registered sensor identity, its calibration and its measurement uncertainty"},
    ]),
    ("03-14-fw-relations.adoc",
     "== Framework terms — passport relationship algebra", [
        {"term": "association",
         "definition": "typed, navigational passport relationship, such as compatibility, supply or same-maker, carrying no lifecycle impact"},
        "dpp-0142",
        {"term": "membership",
         "definition": "temporal relationship between a passport and a group node, such as a shipment, consignment, kit, fleet or recall set"},
        {"term": "group node",
         "definition": "queryable grouping of passports that receives a passport of its own only when the group is itself placed on the market"},
        {"term": "binding strength",
         "definition": "declared permanence of an installation binding, ranging from reversible fastening to destructive integration"},
        {"term": "slot identity",
         "definition": "parent-scoped identifier of an installation position by which an installed child is re-identified within its parent"},
        {"term": "pairing",
         "definition": "recorded binding of a child to its parent context, by firmware, key or module, that is re-established when a component is replaced"},
        {"term": "absorbed component",
         "definition": "input whose identity dissolves into its parent and is therefore modelled as a transformation input rather than a live child, recorded at the finest available granularity as dormant identifiers"},
        "dpp-0143",
        "dpp-0144",
        "dpp-0134",
        {"term": "custodian",
         "definition": "actor that currently holds the live event segment of a subject's record and is authorized to append custody-relevant events to it"},
    ]),
    ("03-15-fw-visibility.adoc",
     "== Framework terms — visibility and enumeration resistance", [
        "dpp-0136", "dpp-0137", "dpp-0138", "dpp-0139", "dpp-0140",
        {"term": "owner-push disclosure",
         "definition": "disclosure of instance state initiated by the owner, such as a warranty registration, as the default manufacturer-visibility channel",
         "notes": ["A manufacturer-initiated pull of instance state is not a channel of the framework; authority-based compulsion of traversal is a separate, legal-basis-governed mechanism."]},
        {"term": "dark identity",
         "definition": "identity that is resolvable only within a restricted resolution domain, such as a national domain, and never enters the global resolver"},
        {"term": "confidential profile",
         "definition": "registered profile whose register item is non-public and which carries restricted resolution, edge-visibility and traversal fields, used for defence and sovereignty configurations"},
    ]),
    ("03-16-fw-federation.adoc",
     "== Framework terms — trust semantics, degradation and federation", [
        {"term": "trust marker",
         "definition": "graded indicator attached to every element or event stating its trust provenance: unsigned, self-declared, third-party attested, multi-signed or log-anchored",
         "notes": ["Trust is graded, not mandated; profiles set minimum signing per data class."]},
        {"term": "master list",
         "definition": "globally multi-witnessed list of trust lists, co-signed by a quorum of independent logs, by which verifiers cross-recognize jurisdictional trust authorities"},
        {"term": "revocation window",
         "definition": "explicit start and end interval carried by a distrust declaration, within which affected credentials are void and outside which they are re-validated",
         "notes": ["The reason for revocation determines retroactivity: prospective reasons preserve earlier as-of verifications; misissuance voids validity from the beginning."]},
        {"term": "three verification readings",
         "definition": "three legally distinct readings of a verification result — evidentiary, current-state and cryptographic — each of which a verdict states explicitly",
         "notes": ["The evidentiary reading asks what a diligent verifier could know at the time; the current-state reading voids fraud from the beginning; the cryptographic reading covers signature and chain validity alone."]},
        {"term": "freshness verdict",
         "definition": "explicit, displayable assessment of how current a served state is relative to its declared freshness bound, degrading visibly when data is stale or offline"},
        {"term": "coverage report",
         "definition": "statement accompanying a verdict enumerating which elements, trust anchors and registry items the verification covered"},
        {"term": "discovery registry",
         "definition": "federated registry of record for passport services and semantics, in which profile shapes, protocol bindings, verification mechanisms and service endpoints are versioned, signed, log-anchored items discoverable by any conforming client",
         "notes": ["The registry holds descriptors of services and shapes, never records of things."]},
        {"term": "service descriptor",
         "definition": "signed registry item describing a service by operator identity and credential, service class, endpoints, protocol binding, jurisdiction, residency class, status and succession pointer"},
        {"term": "protocol binding",
         "definition": "registered specification of a wire grammar, media types, version and conformance suite by which an interaction with a service or a device is conducted"},
        {"term": "verification mechanism bundle",
         "definition": "assembled set of registered items naming the cryptographic suite, trust framework, trust-list endpoints, revocation mechanism and acceptance-policy template under which a client verifies"},
        {"term": "listing gate",
         "definition": "registered predicate evaluated by a marketplace over passport status and standing without holding passport data, admitting or refusing listings"},
        {"term": "operator credential",
         "definition": "scoped, threshold-issued credential by which an operator signs registry items and service attestations",
         "notes": ["Appends claiming a role outside the credential's scope degrade the trust marker; they do not pass silently."]},
        {"term": "onboarding ceremony",
         "definition": "threshold admission ceremony by which an operator joins the service federation, or a trust authority joins the master list, accepting continuity and succession obligations"},
        {"term": "read federation",
         "definition": "federation tier in which any party consumes the registry and trust bundles without an admission ceremony"},
        {"term": "service federation",
         "definition": "federation tier in which operators register services under signed descriptors and accept continuity and succession obligations"},
        {"term": "trust federation",
         "definition": "federation tier in which trust authorities join the master list by threshold admission and jurisdictional profiles cross-recognize one another"},
        {"term": "seed bundle",
         "definition": "bootstrap set of registry endpoints and trust anchors with which a conforming client first initializes, resolving the circular dependence between registry discovery and trust"},
        {"term": "registry pinning",
         "definition": "binding of a passport manifest or a verdict to exact registry items by item, version and hash, so that later registry changes never alter what a past issuance must satisfy"},
    ]),
]


def concept_block(item, anchor):
    if isinstance(item, str):
        return render_term(concepts[item], anchor)
    d = {
        "term": item["term"],
        "definition": item["definition"],
        "terms": [{"type": "expression", "normative_status": "preferred",
                   "designation": item["term"]}]
        + [{"type": "expression", "normative_status": "admitted",
            "designation": a} for a in item.get("alt", [])],
        "notes": item.get("notes", []),
        "examples": [],
        "sources": [],
    }
    return render_term(d, anchor)


def main():
    os.makedirs(OUTDIR, exist_ok=True)
    stats = {"sourced": {}, "framework": {}, "counts": {}}
    total = 0
    fw_from_dataset = 0
    fw_new = 0

    for fname, header, section in SOURCED_CLAUSES:
        entries = [c for tid, c in sorted(concepts.items())
                   if c["section"] == section]
        stats["sourced"][section] = len(entries)
        body = [header, ""]
        for c in entries:
            body.append(render_term(c, f"term-{c['termid']}"))
            total += 1
        open(os.path.join(OUTDIR, fname), "w").write(
            "// generated from the UniDPP glossarist dataset — do not edit by hand\n"
            + "\n".join(body))

    for i, (fname, header, items) in enumerate(FRAMEWORK_CLAUSES):
        body = ["[heading=terms and definitions]", header, ""]
        if i == 0:
            body.append(FW_UMBRELLA)
            body.append("")
        for j, item in enumerate(items, start=1):
            if isinstance(item, str):
                anchor = f"term-{item}"
                fw_from_dataset += 1
            else:
                anchor = f"term-fw-{i+8}-{j:02d}"
                fw_new += 1
            body.append(concept_block(item, anchor))
            total += 1
        stats["framework"][header] = len(items)
        open(os.path.join(OUTDIR, fname), "w").write(
            "// framework-defined entries (UniDPP) — generated, do not edit by hand\n"
            + "\n".join(body))

    stats["counts"] = {
        "total_entries": total,
        "dataset_concepts_used": sum(v for v in stats["sourced"].values())
        + fw_from_dataset,
        "sourced_entries": sum(v for v in stats["sourced"].values()),
        "framework_from_dataset": fw_from_dataset,
        "framework_new": fw_new,
        "framework_total": fw_from_dataset + fw_new,
    }

    # bibliography of actually-cited anchors
    biblio = [BIBLIO[a] for a in sorted(cited_anchors)]
    biblio.sort(key=lambda s: s.lower())
    open(os.path.join(OUTDIR, "zz-references-body.adoc"), "w").write(
        "\n".join(biblio) + "\n")
    stats["cited_anchors"] = sorted(cited_anchors)
    stats["dropped_refs"] = sorted(set(dropped_notes))
    json.dump(stats, open(os.path.join(OUTDIR, "..", "..", "..",
                                       "build_stats.json"), "w"), indent=2)
    print(json.dumps(stats["counts"], indent=2))
    print("cited anchors:", len(cited_anchors))
    if dropped_notes:
        print("dropped unresolvable refs:", sorted(set(dropped_notes)))


if __name__ == "__main__":
    main()
