#!/usr/bin/env ruby
# frozen_string_literal: true

# Generate Metanorma ISO 25534-1 PWI term-entry sections from the
# UniDPP glossarist concept dataset.
#
# Source of truth: ~/src/glossarist/unidpp/datasets/dpp/concepts/*.yaml
# (145 concepts after the 2026-09-07 merger of dpp-0001 and dpp-0004).
#
# Output: /Users/mulgogi/src/calconnect/cc-dpp-vocabulary/sources/iso-25534-1-pwi/sections/
#
# Editorial decisions applied by this generator (per the dataset audit):
#
#   * D-01: dpp-0006 and dpp-0007 are merged into one concept
#     `unique identifier` aligned to the ISO/IEC 15459-1 lineage
#     (ISO 29404:2015, 3.26). The EN family formulation is recorded
#     as a regional variant (status: modified).
#   * D-02: dpp-0032 and dpp-0033 are merged into one concept
#     `economic operator`. The broader EN 18221:2026 formulation is
#     preferred; the narrower EN 18219 / EN 18220 formulation is
#     recorded as a regional variant (status: similar).
#   * D-03: dpp-0086 and dpp-0087 are merged into one concept
#     `interoperability` aligned to ISO/IEC 22123-1:2023, 3.6.1.
#     The ISO 18435-1:2009, 3.12 formulation is recorded as a
#     regional variant (status: similar).
#   * D-04: the admitted designation `product` is removed from
#     dpp-0071 (collides with dpp-0060).
#   * D-05: the admitted designation `identifier` is removed from
#     dpp-0008 (collides with dpp-0031).
#   * H-01: the preferred designation of the merged unique-identifier
#     concept is set to lower case (resolution of the dpp-0007
#     capitalisation).
#   * H-02: the admitted designation of dpp-0079 is set to lower case
#     (`recovery time objective`).
#   * H-03: dpp-0081 gains an admitted long-form designation
#     `RFID privacy impact assessment process`.
#   * H-04: dpp-0023, dpp-0078, dpp-0079 swap preferred and admitted
#     designations so that the long form is preferred.
#   * I-01: six ISO/AWI 25534-1 terms not in the dataset are added
#     (`circular economy`, `product circularity`, `validation`,
#     `verification`, `value chain`) and traceability gains the
#     AWI 3.5 attribution.
#   * I-02: the merged unique-identifier concept gains a source
#     citation to ISO/IEC 15459-1 (the lineage identified in the
#     CWA 18291:2025 note).
#   * I-03: dpp-0015 and dpp-0016 gain lineage citations to
#     ISO/IEC 18975:2024.
#   * I-04: dpp-0085 gains a lineage citation to ISO/IEC 20248:2022.
#   * X-01: parenthetical EN internal clause cross-references are
#     replaced by dataset termid references where the target concept
#     is in the dataset.
#
# The generator reads the dataset via the unidpp_glossarist models
# and emits valid Metanorma ISO term entries (no prose connectors in
# [.source] blocks; sources are listed as comma-separated citations
# with a trailing ", modified" where the dataset records the variant).

require "unidpp_glossarist"
require "yaml"
require "fileutils"

DATASET = File.expand_path("~/src/glossarist/unidpp/datasets/dpp/concepts")
OUT     = File.expand_path(
  "~/src/calconnect/cc-dpp-vocabulary/sources/iso-25534-1-pwi/sections"
)

# ---------------------------------------------------------------------------
# Merge map: source termid => { into:, prefer: }. The source termid is
# dropped from the section listing; the target termid gains the merged
# information. `prefer` states which definition becomes preferred:
#   :source  — the dropped concept's definition is promoted (D-01: the
#              ISO 29404 / ISO/IEC 15459 formulation; D-02: the broader
#              EN 18221 formulation);
#   :primary — the retained concept's definition stays preferred
#              (D-03: the ISO/IEC 22123-1 formulation).
# ---------------------------------------------------------------------------
MERGES = {
  "dpp-0007" => { "into" => "dpp-0006", "prefer" => :source },
  "dpp-0033" => { "into" => "dpp-0032", "prefer" => :source },
  "dpp-0087" => { "into" => "dpp-0086", "prefer" => :primary },
}.freeze

# ---------------------------------------------------------------------------
# Additions from ISO/AWI 25534-1 that are not in the dataset.
# Each entry is { termid:, term:, section:, terms:, definition:, notes:,
# examples:, sources: }.
# ---------------------------------------------------------------------------
AWI_ADDITIONS = [
  { "termid" => "awi-3.3", "term" => "circular economy",
    "section" => "lifecycle-and-events",
    "terms" => [{ "type" => "expression", "normative_status" => "preferred",
                  "designation" => "circular economy" }],
    "definition" => "products and materials are designed in such a way that " \
                    "they can be reused, remanufactured, recycled or recovered " \
                    "and thus maintained in the economy for as long as possible, " \
                    "along with the resources of which they are made, and the " \
                    "generation of waste, especially hazardous waste, is avoided " \
                    "or minimized and greenhouse gas emissions are prevented or " \
                    "reduced, can contribute significantly to sustainable " \
                    "consumption and production",
    "notes" => [],
    "examples" => [],
    "sources" => [
      { "origin" => { "ref" => "ISO/AWI 25534-1 (2026-09-05 draft)",
                      "clause" => "3.3" },
        "type" => "authoritative" },
      { "origin" => { "ref" => "UNEP/EA.4/Res.1", "clause" => "" },
        "type" => "lineage" },
    ] },
  { "termid" => "awi-3.4", "term" => "product circularity",
    "section" => "lifecycle-and-events",
    "terms" => [{ "type" => "expression", "normative_status" => "preferred",
                  "designation" => "product circularity" }],
    "definition" => "refers to repairing, reusing and remanufacturing " \
                    "equipment, and harvesting and recycling metals " \
                    "indefinitely through product design and collection " \
                    "processes",
    "notes" => [],
    "examples" => [],
    "sources" => [
      { "origin" => { "ref" => "ISO/AWI 25534-1 (2026-09-05 draft)",
                      "clause" => "3.4" },
        "type" => "authoritative" },
      { "origin" => { "ref" => "UNEP, Toledano, Bauch and Arnold 2023",
                      "clause" => "" },
        "type" => "lineage" },
    ] },
  { "termid" => "awi-3.6", "term" => "validation",
    "section" => "trust-and-verification",
    "terms" => [{ "type" => "expression", "normative_status" => "preferred",
                  "designation" => "validation" }],
    "definition" => "confirmation of the plausibility for a specific intended " \
                    "use or application through the provision of objective " \
                    "evidence that specified requirements have been met",
    "notes" => [
      "Compared with the source: numbers referencing to related sections and " \
      "the accompanying note have been removed from the definition.",
    ],
    "examples" => [],
    "sources" => [
      { "origin" => { "ref" => "ISO/AWI 25534-1 (2026-09-05 draft)",
                      "clause" => "3.6" },
        "type" => "authoritative" },
      { "origin" => { "ref" => "ISO/IEC 17000:2020", "clause" => "6.5" },
        "type" => "lineage", "status" => "modified",
        "modification" => "Numbers referencing to related sections and the " \
                          "accompanying note have been removed from the " \
                          "definition." },
    ] },
  { "termid" => "awi-3.7", "term" => "verification",
    "section" => "trust-and-verification",
    "terms" => [{ "type" => "expression", "normative_status" => "preferred",
                  "designation" => "verification" }],
    "definition" => "confirmation of the truthfulness through the provision " \
                    "of objective evidence that specified requirements have " \
                    "been fulfilled",
    "notes" => [
      "Compared with the source: numbers referencing to related sections and " \
      "the accompanying note have been removed from the definition.",
    ],
    "examples" => [],
    "sources" => [
      { "origin" => { "ref" => "ISO/AWI 25534-1 (2026-09-05 draft)",
                      "clause" => "3.7" },
        "type" => "authoritative" },
      { "origin" => { "ref" => "ISO/IEC 17000:2020", "clause" => "6.6" },
        "type" => "lineage", "status" => "modified",
        "modification" => "Numbers referencing to related sections and the " \
                          "accompanying note have been removed from the " \
                          "definition." },
    ] },
  { "termid" => "awi-3.8", "term" => "value chain",
    "section" => "lifecycle-and-events",
    "terms" => [{ "type" => "expression", "normative_status" => "preferred",
                  "designation" => "value chain" }],
    "definition" => "all activities and stakeholders that provide or receive " \
                    "value from designing, developing, making, distributing, " \
                    "retailing, and consuming a product (or providing the " \
                    "service that a product renders), including the extraction " \
                    "and supply of raw materials, as well as activities " \
                    "involving the product after its useful service life has " \
                    "ended",
    "notes" => [
      "Compared with the source: the source is framed for the textile " \
      "sector; the AWI draft reformulates the term in a sector-neutral form.",
    ],
    "examples" => [],
    "sources" => [
      { "origin" => { "ref" => "ISO/AWI 25534-1 (2026-09-05 draft)",
                      "clause" => "3.8" },
        "type" => "authoritative" },
      { "origin" => { "ref" => "UNEP Job no. DTI/2532/PA", "clause" => "" },
        "type" => "lineage", "status" => "modified",
        "modification" => "Changed from textile perspective to neutral." },
    ] },
]

# Additional lineage citations (applied to existing concepts)
LINEAGE_ADDITIONS = {
  "dpp-0006" => [
    { "origin" => { "ref" => "ISO/IEC 15459-1", "clause" => "" },
      "type" => "lineage", "status" => "identical",
      "modification" => "The ISO 29404:2015, 3.26 formulation and the " \
                        "CWA 18291:2025, 3.3 definition originate in the " \
                        "ISO/IEC 15459 family of standards on unique " \
                        "identification." },
  ],
  "dpp-0015" => [
    { "origin" => { "ref" => "ISO/IEC 18975:2024", "clause" => "" },
      "type" => "lineage", "status" => "related",
      "modification" => "ISO/IEC 18975:2024 specifies the encoding and " \
                        "resolving of identifiers over HTTP; the resolution " \
                        "concept is aligned with that standard's " \
                        "link-resolver model." },
  ],
  "dpp-0016" => [
    { "origin" => { "ref" => "ISO/IEC 18975:2024", "clause" => "" },
      "type" => "lineage", "status" => "related",
      "modification" => "ISO/IEC 18975:2024 specifies the encoding and " \
                        "resolving of identifiers over HTTP; the resolver " \
                        "concept is aligned with that standard's " \
                        "link-resolver model." },
  ],
  "dpp-0085" => [
    { "origin" => { "ref" => "ISO/IEC 20248:2022", "clause" => "" },
      "type" => "lineage", "status" => "related",
      "modification" => "ISO/IEC 20248:2022 specifies a digital signature " \
                        "data structure schema for automatic identification " \
                        "and data capture techniques; the ESDC concept is " \
                        "aligned with that standard's data-structure model." },
  ],
  "dpp-0059" => [
    { "origin" => { "ref" => "ISO/AWI 25534-1 (2026-09-05 draft)",
                    "clause" => "3.2" },
      "type" => "authoritative", "status" => "identical",
      "modification" => "The AWI draft co-cites ISO 14040:2006, 3.1 as the " \
                        "international lineage." },
  ],
  "dpp-0068" => [
    { "origin" => { "ref" => "ISO/AWI 25534-1 (2026-09-05 draft)",
                    "clause" => "3.5" },
      "type" => "authoritative", "status" => "identical",
      "modification" => "The AWI draft adopts the same definition from " \
                        "ISO 9000:2015 with the addition of \"in a value " \
                        "chain\" to identify the traceability domain." },
  ],
}

# Source citations to drop from the rendered document (render-level
# only; the dataset keeps them). The dropped citations are bare,
# clause-less citations of standards whose catalogue status triggers a
# rendering defect (a relaton status footnote is injected into the
# [.source] modification element, which is schema-invalid). The
# identical text is carried by the dated citation kept in the block.
DROP_SOURCES = {
  # EN ISO 14025:2010, 3.16 (kept) is the identical adoption of
  # ISO 14025:2006 (dropped, bare citation).
  "dpp-0040" => [/\AISO 14025:2006\z/],
}

# Notes to add to existing concepts (render-level only).
NOTE_ADDITIONS = {
  # ISO 9000:2015 lineage recorded as a note rather than a bare
  # [.source] citation (relaton status footnote is schema-invalid in
  # the modification element; inline citations in notes are legal).
  "dpp-0068" => [
    "Lineage: ISO/AWI 25534-1, 3.5 adopts this definition from " \
    "ISO 9000:2015, modified by the addition of \"in a value chain\".",
  ],
}

# Definition edits: strip the leading article from the preferred
# definition where the source text begins with one (ISO/IEC Directives,
# Part 2, 16.5.8).
DEFINITION_EDITS = {
  "dpp-0001" => ->(d) {
    d.merge("definition" => d["definition"].to_s.sub(/\AA\s+/i, ""))
  },
}

# Parenthetical EN internal clause references in definitions and notes
# are replaced by Metanorma concept cross-references (the {{term}}
# syntax) so that the cross-reference resolves within the document
# rather than carrying the EN source's clause number (X-01).
XREF_REPLACEMENTS = {
  "dpp-0006" => [[/\(3\.1\.25\)/, "({{unique product identifier}})"],
                 [/\(3\.1\.22\)/, "({{unique economic operator identifier}})"],
                 [/\(3\.1\.23\)/, "({{unique facility identifier}})"]],
  "dpp-0016" => [[/\(3\.1\.18\)/, "({{resolution}})"]],
  "dpp-0025" => [[/\(term 3\.15\)/, "({{radio-frequency identification}})"]],
  "dpp-0028" => [[/\(3\.1\.11\)/, "({{model}})"]],
  "dpp-0029" => [[/\(3\.1\.11\)/, "({{model}})"]],
  "dpp-0034" => [[/\(3\.1\)/,    "({{economic operator}})"]],
  "dpp-0035" => [[/\(3\.3\)/,    "({{digital product passport service provider}})"],
                 [/\(3\.2\)/,    "({{digital product passport}})"],
                 [/\(3\.1\)/,    "({{economic operator}})"]],
  "dpp-0036" => [[/\(3\.3\)/,    "({{digital product passport service provider}})"],
                 [/\(3\.2\)/,    "({{digital product passport}})"]],
  "dpp-0060" => [[/\(3\.1\.14\)/, "({{placed on the market}})"],
                 [/\(3\.1\.17\)/, "({{put into service}})"]],
  "dpp-0063" => [[/\(3\.2\)/,      "({{digital product passport}})"]],
  "dpp-0090" => [[/\(3\.3\)/,      "({{method}})"]],
  "dpp-0091" => [[/\(3\.3\)/,      "({{method}})"]],
  "dpp-0093" => [[/\(3\.3\)/,      "({{method}})"]],
  "dpp-0094" => [[/\(3\.3\)/,      "({{method}})"]],
}.freeze

# Designation hygiene edits
DESIGN_EDITS = {
  "dpp-0071" => ->(terms) { terms.reject { |t| t["designation"] == "product" } },
  "dpp-0008" => ->(terms) { terms.reject { |t| t["designation"] == "identifier" } },
  "dpp-0079" => ->(terms) {
    terms.map { |t| t["designation"] == "Recovery Time Objective" ?
                 t.merge("designation" => "recovery time objective") : t }
  }.then { |f1|
    _swap = ->(terms) {
      pref = terms.find { |t| t["normative_status"] == "preferred" }
      adm = terms.find { |t| t["normative_status"] == "admitted" }
      if pref && adm && pref["designation"] == "RTO"
        [
          pref.merge("designation" => "recovery time objective"),
          adm.merge("designation" => "RTO"),
        ]
      else
        terms
      end
    }
    ->(terms) { _swap.call(f1.call(terms)) }
  },
  "dpp-0081" => ->(terms) {
    existing = terms.map { |t| t["designation"] }
    unless existing.include?("RFID Privacy Impact Assessment Process")
      terms + [{ "type" => "expression",
                 "normative_status" => "admitted",
                 "designation" => "RFID privacy impact assessment process" }]
    else
      terms
    end
  },
  "dpp-0023" => ->(terms) {
    # NFC preferred -> near field communication preferred; NFC admitted
    pref = terms.find { |t| t["normative_status"] == "preferred" }
    adm = terms.find { |t| t["normative_status"] == "admitted" }
    if pref && adm && pref["designation"] == "NFC" &&
       adm["designation"] == "near field communication"
      [
        pref.merge("designation" => "near field communication"),
        adm.merge("designation" => "NFC"),
      ]
    else
      terms
    end
  },
  "dpp-0078" => ->(terms) {
    pref = terms.find { |t| t["normative_status"] == "preferred" }
    adm = terms.find { |t| t["normative_status"] == "admitted" }
    if pref && adm && pref["designation"] == "RPO"
      [
        pref.merge("designation" => "recovery point objective"),
        adm.merge("designation" => "RPO"),
      ]
    else
      terms
    end
  },
}

# ---------------------------------------------------------------------------
# Source citation -> bibliography anchor mapping
# ---------------------------------------------------------------------------
REF_TO_ANCHOR = {
  /EN\s+18216:2026/                           => "EN18216",
  /EN\s+18219:2026/                           => "EN18219",
  /EN\s+18220:2026/                           => "EN18220",
  /EN\s+18221:2026/                           => "EN18221",
  /EN\s+18222:2026/                           => "EN18222",
  /EN\s+18223:2026/                           => "EN18223",
  /EN\s+18239\s*\(prEN\s+18239:2025\)/        => "EN18239",
  /prEN\s+18239:2025/                         => "EN18239",
  /EN\s+18246\s*\(prEN\s+18246:2025\)/        => "EN18246",
  /prEN\s+18246:2025/                         => "EN18246",
  /CWA\s+18291:2025/                          => "CWA18291",
  /ISO\/AWI\s+25534-1\s*\(2026-09-05\s*draft\)/=> "AWI25534",
  /ISO\/AWI\s+25534-1/                        => "AWI25534",
  /IDTA-01001-3\.2:2026/                      => "IDTA01001",
  /IEC\s+63278-1:2023/                        => "IEC63278",
  /ISO\s+59004:2024/                          => "ISO59004",
  /ISO\s+59004/                               => "ISO59004",
  /ISO\s+59040/                               => "ISO59040",
  /UNECE\s+Recommendation\s+No\.\s+46/        => "UNECE46",
  /ISO\s+5157:2023/                           => "ISO5157",
  /IEC\s+TR\s+62390:2005/                     => "IECTR62390",
  /IEC\s+TR\s+62390:2005-01/                  => "IECTR62390",
  /ISO\s+29404:2015/                          => "ISO29404",
  /ISO\/IEC\s+27031/                          => "ISOIEC27031",
  /ECLASS/                                    => "ECLASS",
  /ISO\s+24619:2011/                          => "ISO24619",
  /EN\s+ISO\/IEC\s+24760-1/                   => "ISOIEC24760",
  /ISO\/IEC\s+6523-1/                         => "ISOIEC6523",
  /ISO\/IEC\s+19762/                          => "ISOIEC19762",
  /ISO\s+23234:2021/                          => "ISO23234",
  /EN\s+ISO\s+14025:2010/                     => "ISO14025EN",
  /ISO\s+14025:2006/                          => "ISO14025",
  /ISO\s+9000/                                => "ISO9000",
  /ISO\/TS\s+24533:2012/                      => "ISOTS24533",
  /ISO\s+24533-2:2022/                        => "ISO24533-2",
  /ISO\s+14040:2006/                          => "ISO14040",
  /ISO\/IEC\/IEEE\s+8802-1AR/                 => "IEEE8802-1AR",
  /ISO\s+7498-2:1989/                         => "ISO7498-2",
  /ISO\/IEC\s+29180:2012/                     => "ISOIEC29180",
  /EN\s+ISO\/IEC\s+27000/                     => "ISOIEC27000",
  /ISO\/IEC\s+17000:2020/                     => "ISOIEC17000",
  /ISO\/IEC\s+Guide\s+2:2004/                 => "ISOIECGuide2",
  /IEC\s+TS\s+62443-1-1/                      => "IECTS62443",
  /ISO\/IEC\s+22123-1:2023/                   => "ISOIEC22123",
  /ISO\s+18435-1:2009/                        => "ISO18435",
  /ISO\s+18308:2011/                          => "ISO18308",
  /ISO\s+15531-43/                            => "ISO15531",
  /Industrial\s+Internet\s+Vocabulary/        => "IICVOC",
  /Glossary\s+Industrie\s+4\.0/               => "I40GLOSS",
  /ISO\/IEC\s+10746-2/                        => "ISOIEC10746",
  /IEC\s+61499-1/                             => "IEC61499",
  /ISO\s+22095:2020/                          => "ISO22095",
  /ISO\/IEC\s+Guide\s+77-2/                   => "ISOIECGuide77",
  /IEC\s+61360-1:2016/                        => "IEC61360",
  /ISO\s+22274:2013/                          => "ISO22274",
  /IEC\s+60050-741:2020/                      => "IEV741",
  /IEC\s+61666:2010\+AMD1:2021\s+CSV/         => "IEC61666",
  /IEC\s+62569-1/                             => "IEC62569",
  /IEC\s+62890:2016/                          => "IEC62890",
  /ISO\s+9000:2015/                           => "ISO9000",
  /ISO\/IEC\s+15459-1/                        => "ISOIEC15459-1",
  /ISO\/IEC\s+18975:2024/                     => "ISOIEC18975",
  /ISO\/IEC\s+20248:2022/                     => "ISOIEC20248",
  /UNEP\/EA\.4\/Res\.1/                       => "UNEP_EA4_Res1",
  /UNEP,\s*Toledano/                          => "UNEP_Toledano_2023",
  /UNEP\s+Job\s+no\.\s+DTI\/2532/             => "UNEP_DTI2532",
}.freeze

def resolve_anchor(ref)
  REF_TO_ANCHOR.each do |re, anchor|
    return anchor if ref =~ re
  end
  nil
end

# ---------------------------------------------------------------------------
# Citation emission
# ---------------------------------------------------------------------------

def esc(text)
  # AsciiDoc escaping for paragraph text coming from the dataset.
  # Metanorma concept cross-references ({{term}}) are passed through
  # unescaped because the braces denote a passthrough reference, not
  # an attribute substitution.
  out_lines = []
  text.to_s.each_line do |ln|
    s = ln.lstrip
    if s && !s.empty? && %w[. * + - = : > ! | _ ` <].include?(s[0])
      ln = "\\" + ln
    end
    # Unescape \{{ ... }} back to {{ ... }} (concept reference passthrough)
    ln = ln.gsub(/\\\{\\{([^}]+)\}\\}/, '{{\1}}')
    ln = ln.gsub("{", "\\{") unless ln.include?("{{")
    out_lines << ln
  end
  out_lines.join("\n")
end

def emit_cite(anchor, clause)
  if clause && !clause.empty?
    "<<#{anchor},clause=\"#{clause}\">>"
  else
    "<<#{anchor}>>"
  end
end

# Emit a Metanorma [.source] block from a list of source hashes
# (origin.ref, origin.clause, type, status, modification). Multiple sources
# are rendered as comma-separated cross-references with a trailing
# ", modified" / ", similar" suffix where the dataset records the variant.
def emit_source_block(sources)
  return nil if sources.empty?
  lines = []
  # Sort: authoritative first, lineage citations last; within type,
  # identical/related first, modified/restyle/not_equal middle,
  # similar (regional variant) last
  order = sources.sort_by do |s|
    [
      %w[authoritative lineage].index(s["type"]) || 99,
      { "identical" => 0, "related" => 1, "unspecified" => 2,
        "context_added" => 3, "modified" => 4, "restyle" => 5,
        "not_equal" => 6, "generalisation" => 7,
        "specialisation" => 8, "similar" => 9, nil => 10 }[
        s["status"]] || 99,
    ]
  end
  cites = []
  order.each do |s|
    ref = s.dig("origin", "ref").to_s
    clause = s.dig("origin", "clause").to_s
    anchor = resolve_anchor(ref)
    next unless anchor
    cite = emit_cite(anchor, clause)
    status = s["status"]
    if %w[modified restyle context_added not_equal].include?(status)
      cite += ", modified"
    elsif status == "similar"
      cite += ", similar"
    end
    cites << cite
  end
  return nil if cites.empty?
  lines << "[.source]"
  lines << cites.join(", ")
  lines.join("\n") + "\n"
end

# Emit one term entry as Metanorma ISO adoc
def emit_term_entry(d, anchor_override = nil)
  out = []
  anchor = anchor_override || d["termid"]
  # Preferred designation (lowercase per H-01)
  pref = (d["terms"] || []).find { |t| t["normative_status"] == "preferred" }
  alts = (d["terms"] || []).reject { |t| t["normative_status"] == "preferred" }
  heading = pref ? pref["designation"] : d["term"].to_s
  out << "[[#{anchor}]]"
  out << "=== #{heading}"
  alts.each { |a| out << "alt:[#{a["designation"]}]" }
  out << ""
  out << esc(d["definition"].to_s.strip)
  out << ""
  (d["notes"] || []).each do |n|
    n = n.to_s.strip
    next if n.empty?
    lines = n.lines
    first = "NOTE: " + esc(lines.first.to_s.rstrip)
    rest = lines[1..].map { |x| "  " + esc(x.rstrip) }.reject(&:empty?)
    out << ([first] + rest).join("\n")
    out << ""
  end
  (d["examples"] || []).each do |ex|
    ex = ex.to_s.strip
    next if ex.empty?
    out << "[example]"
    out << "--"
    out << esc(ex)
    out << "--"
    out << ""
  end
  sb = emit_source_block(d["sources"] || [])
  if sb
    out << sb
    out << ""
  end
  out.join("\n") + "\n"
end

# ---------------------------------------------------------------------------
# Apply edits and merges to a loaded concept Hash (mutates in place)
# ---------------------------------------------------------------------------

def apply_edits(concepts)
  concepts.each do |tid, d|
    if DEFINITION_EDITS.key?(tid)
      d.replace(DEFINITION_EDITS[tid].call(d))
    end
    if DESIGN_EDITS.key?(tid)
      d["terms"] = DESIGN_EDITS[tid].call(d["terms"] || [])
    end
    if DROP_SOURCES.key?(tid)
      d["sources"] = (d["sources"] || []).reject do |s|
        DROP_SOURCES[tid].any? { |re| s.dig("origin", "ref").to_s =~ re }
      end
    end
    if NOTE_ADDITIONS.key?(tid)
      d["notes"] ||= []
      NOTE_ADDITIONS[tid].each do |n|
        d["notes"] << n unless d["notes"].include?(n)
      end
    end
    if XREF_REPLACEMENTS.key?(tid)
      d["notes"] ||= []
      XREF_REPLACEMENTS[tid].each do |pattern, replacement|
        d["definition"] = d["definition"].to_s.gsub(pattern, replacement)
        d["notes"] = d["notes"].map { |n| n.to_s.gsub(pattern, replacement) }
      end
    end
  end
end

def apply_lineage_additions(concepts)
  LINEAGE_ADDITIONS.each do |tid, sources|
    d = concepts[tid] or next
    (d["sources"] ||= []).concat(sources)
  end
end

def apply_merges!(concepts)
  # For each (source -> into, prefer) merge pair, produce one concept:
  #   * the preferred definition (per `prefer`) becomes the definition;
  #   * the non-preferred concept's definition is recorded as a
  #     regional-variant note;
  #   * the non-preferred concept's regional (EN-family) sources are
  #     demoted to `status: similar`; its international-lineage sources
  #     are recorded with `status: similar`;
  #   * notes from both concepts are carried, dropping any note that
  #     references the merged-away concept by termid.
  MERGES.each do |src_tid, cfg|
    prim_tid = cfg["into"]
    prefer = cfg["prefer"]
    src = concepts.delete(src_tid)
    next unless src
    prim = concepts[prim_tid] or next

    # Determine preferred and demoted sides
    pref_c = prefer == :source ? src : prim
    dem_c  = prefer == :source ? prim : src

    # Carry notes from both concepts, dropping references to the
    # merged-away concept by termid
    merged_notes = []
    [prim["notes"], src["notes"]].each do |ns|
      (ns || []).each do |n|
        next if merged_notes.any? { |x| x.to_s.strip == n.to_s.strip }
        next if n.to_s.include?(src_tid) || n.to_s.include?(prim_tid)
        merged_notes << n
      end
    end

    # Sources: preferred concept's sources first (statuses as recorded);
    # demoted concept's regional (EN-family) and authoritative sources
    # are demoted to `status: similar` (their formulation is the
    # regional variant); its lineage citations pass through unchanged.
    dem_sources = (dem_c["sources"] || []).map do |s|
      anchor = resolve_anchor(s.dig("origin", "ref").to_s)
      is_regional = anchor.to_s.start_with?("EN")
      next s unless is_regional || s["type"] == "authoritative"
      s.merge("status" => "similar",
              "modification" => s["modification"] ||
                "Regional variant; the definition was the preferred " \
                "definition of the merged concept before the merger.")
    end.compact
    new_sources = (pref_c["sources"] || []) + dem_sources

    # Deduplicate sources by anchor+clause (keep first occurrence);
    # modification text of dropped duplicates is preserved as a note
    seen = {}
    deduped = []
    dropped_mods = []
    new_sources.each do |s|
      anchor = resolve_anchor(s.dig("origin", "ref").to_s)
      next unless anchor
      key = [anchor, s.dig("origin", "clause")]
      if seen[key]
        dropped_mods << s["modification"] if s["modification"] &&
                                             !s["modification"].to_s.empty?
        next
      end
      seen[key] = true
      deduped << s
    end

    # Regional-variant note recording the demoted definition
    merged_notes << "Regional variant: the definition recorded from " \
                    "the merged concept pair was: " \
                    "#{dem_c['definition'].to_s.strip}"
    dropped_mods.each { |m| merged_notes << "Recorded variance: #{m}" }

    prim["notes"] = merged_notes
    prim["sources"] = deduped
    prim["definition"] = pref_c["definition"]
    # Keep the retained concept's designations (lower-case per H-01
    # where applicable)
  end
end

# ---------------------------------------------------------------------------
# Build a section from a list of concept Hashes
# ---------------------------------------------------------------------------

def build_section_file(fname, header, concepts_for_section, extra_notes: nil)
  body = []
  body << "[heading=terms and definitions]"
  body << header
  body << ""
  if extra_notes
    extra_notes.each do |n|
      body << n
      body << ""
    end
  end
  concepts_for_section.sort_by { |d| d["termid"].to_s.sub(/\Aawi-/, "z-") }.each do |d|
    body << emit_term_entry(d)
  end
  File.write(File.join(OUT, fname),
             "// generated from the UniDPP glossarist dataset - do not edit by hand\n" +
             body.join("\n"))
end

# ---------------------------------------------------------------------------
# Load dataset
# ---------------------------------------------------------------------------

def load_concepts
  concepts = {}
  Dir.glob("#{DATASET}/concept-*.yaml").sort.each do |p|
    d = YAML.load_file(p)
    concepts[d["termid"]] = d
  end
  # AWI additions
  AWI_ADDITIONS.each do |d|
    d["language_code"] ||= "eng"
    concepts[d["termid"]] = d
  end
  concepts
end

# ---------------------------------------------------------------------------
# Section partition (with merges applied)
# ---------------------------------------------------------------------------

SECTION_HEADERS = [
  ["03-1-dpp.adoc", "== Terms related to the digital product passport",
   "digital-product-passport"],
  ["03-2-identity.adoc", "== Terms related to identity and carriers",
   "identity-and-carriers"],
  ["03-3-actors.adoc", "== Terms related to actors and issuance",
   "actors-and-issuance"],
  ["03-4-lifecycle.adoc", "== Terms related to lifecycle and events",
   "lifecycle-and-events"],
  ["03-5-trust.adoc", "== Terms related to trust and verification",
   "trust-and-verification"],
  ["03-6-semantics.adoc", "== Terms related to semantics and profiles",
   "semantics-and-profiles"],
  ["03-7-measurement.adoc", "== Terms related to measurement and material flow",
   "measurement"],
].freeze

# ---------------------------------------------------------------------------
# Framework terms (from the dead agent's generator, verbatim in the
# dataset's framework architecture). These are authored here (no [.source])
# per the task brief: a term without a source is ours.
# ---------------------------------------------------------------------------

FRAMEWORK_TERMS = {
  "03-8-fw-profiles.adoc" => [
    ["term-dpp-0124", "profile",
     "registered, versioned object that binds a set of data points, " \
     "transforms, cryptographic suites, trust requirements, access " \
     "policies, presentation requirements and a trigger predicate to " \
     "the neutral core passport, constraining and transforming, but " \
     "never redefining, the single definition of each data point",
     ["Composition is three-axial: jurisdiction, sector, characteristic.",
      "Each profile is a projection function, view(twinState, profile, " \
      "actor), whose projection may transform and not merely select.",
      "Profiles constrain and transform; inter-profile disagreement is " \
      "expected and auditable, while intra-class contradiction is an " \
      "integrity incident (single definition, many constraints)."]],
    ["term-dpp-0127", "lens",
     "profile conceived as a calibrated measuring instrument placed on " \
     "the digital twin, which selects and transforms without altering " \
     "the observed scene",
     ["The mount, the profile interface on the neutral core, is the " \
      "standardized element: any registered lens by any maker attaches " \
      "to it.",
      "A lens publishes its calibration (version and cited rules), its " \
      "uncertainty and its decision rules; it is subject to pattern " \
      "approval at registration and to periodic re-verification through " \
      "conformance runs.",
      "Verification path-finds from any render through the lens and its " \
      "fact chain to an anchor in the verifier's trust bundle."]],
    ["term-fw-8-03", "lens mount",
     "standardized interface of the neutral core through which any " \
     "registered profile is attached to and operates on the record of " \
     "the subject, such that profiles from any registering authority " \
     "compose without proprietary binding",
     ["The mount, not any single profile technology, is the interoperation " \
      "point; standardizing it precludes lock-in to a proprietary profile " \
      "mechanism."]],
    ["term-fw-8-04", "jurisdiction profile",
     "profile that binds the data points, transforms, cryptographic " \
     "suites, trust requirements, access rules, presentation and carrier " \
     "requirements enacted by the law of a given jurisdiction",
     ["Conflicting regional rules are registered as distinct data " \
      "elements harmonized to a common concept; they are not merged."]],
    ["term-fw-8-05", "sector overlay",
     "profile that composes with other profiles to add the data points, " \
     "transforms and rules applicable to an industry sector, such as " \
     "electronics, textiles, batteries, construction, tyres or packaging",
     []],
    ["term-fw-8-06", "applicable law",
     "totality of legal rules that apply to a subject placed on a market, " \
     "represented in the passport system by the corresponding " \
     "jurisdiction profile and its dated applicability bindings",
     []],
    ["term-fw-8-07", "as-of query",
     "query against the event-sourced record of a subject that " \
     "reconstructs the state that was legally valid at a specified past " \
     "time",
     ["As-of queries are answered from notarized snapshots, log anchoring " \
      "and recorded profile-version bindings, for example to establish " \
      "whether a product was compliant when sold."]],
    ["term-fw-8-08", "trust list",
     "signed, registry-deposited list of the trust anchors accredited " \
     "to act under a given profile or jurisdiction, served with status " \
     "and revocation information",
     ["Jurisdictional trust lists relate to one another through a " \
      "multi-witnessed master list."]],
  ],
  "03-9-fw-projection.adoc" => [
    ["term-dpp-0126", "projection",
     "deterministic, registered and legally cited view of the " \
     "testimonial record of a governed digital twin, computed under a " \
     "profile from the event-sourced change log",
     ["The passport is the legal materialized view of the twin; the " \
      "twin is the source of truth.",
      "Notarized snapshots support as-of queries, which answer what " \
      "was legally true at a given time.",
      "Any conforming twin can emit the view; the projection is " \
      "defined representation-neutrally."]],
    ["term-fw-9-02", "materialized view",
     "rendered, citable result of a projection, materialized at a point " \
     "in time for serving and verification",
     ["The digital product passport is the legal materialized view of " \
      "the digital twin."]],
    ["term-fw-9-03", "child passport",
     "passport of a component or sub-product that is independently placed " \
     "on the market or independently regulated, referenced by identity " \
     "from the passport of the composite product",
     ["Children join by identity reference, never by data copying; " \
      "roll-up views are computed from the references."]],
    ["term-fw-9-04", "containment event",
     "typed event recording that one passport is physically or " \
     "structurally contained in another, retained for genealogy and " \
     "recall traversal and never transferring authority",
     []],
    ["term-fw-9-05", "genealogy",
     "complete directed ancestry of a passport, traced through " \
     "transformation and containment events from raw-material and " \
     "component passports to the present subject",
     []],
    ["term-dpp-0146", "as-of state",
     "state of a subject reconstructed from its event-sourced record at " \
     "a specified past time, anchored by a notarized snapshot so that " \
     "queries can answer what was legally true at that time",
     ["The two authoritative query modes are the live view (freshness-" \
      "labelled) and the notarized as-of snapshot (log-anchored); legal " \
      "purpose selects the mode.",
      "Transformation events hash-link their inputs by as-of state hash, " \
      "and profile-version bindings recorded as lifecycle events make " \
      "manifest history as-of-reconstructable, answering questions " \
      "such as whether a product was compliant when sold.",
      "Mirrors and caches are always as-of stamped; the projection is " \
      "computed from the record, so as-of queries are reproducible."]],
    ["term-fw-9-07", "offline minimum",
     "subset of passport data and verification material specified as " \
     "sufficient for offline verification of identity and status from " \
     "the data carrier alone",
     ["The Tier-A payload is the carrier-embedded realization of the " \
      "offline minimum."]],
    ["term-fw-9-08", "degradation ladder",
     "ordered set of service tiers by which availability and " \
     "verification degrade explicitly, from the served full passport " \
     "through the carrier-embedded minimum to the archival record",
     ["Stale or offline data is always marked as such, never silently " \
      "passed as current."]],
    ["term-dpp-0131", "Tier-A payload",
     "carrier-embedded minimum viable passport, comprising the product " \
     "identifier, the resolver URI, the economic operator identifier, " \
     "the status, the critical safety or recall flag, the validity and " \
     "multi-suite compressed signatures, sized to the data carrier and " \
     "verifiable offline against pre-cached trust anchors",
     ["The three-tier degradation ladder comprises Tier A (carrier-" \
      "embedded minimum), Tier B (served full passport) and Tier C " \
      "(archival).",
      "Stale or offline data degrades explicitly through freshness " \
      "verdicts and never passes silently."]],
    ["term-fw-9-10", "Tier-B payload",
     "full passport content, served through resolution and hosting " \
     "services in accordance with the applicable profile",
     []],
    ["term-fw-9-11", "Tier-C archive",
     "notarized archival form of the passport record, retained for " \
     "persistence beyond the operational lifetime of any single provider",
     []],
  ],
  "03-10-fw-lattice.adoc" => [
    ["term-fw-10-01", "provenance class",
     "declared category of a fact according to how it entered the " \
     "record: declared at type level, measured at instance level under " \
     "a stated method and uncertainty, or computed by a stated transform",
     []],
    ["term-fw-10-02", "precedence rule",
     "rule declared by a profile stating which provenance class prevails " \
     "when facts about the same subject disagree",
     ["The default precedence is instance-measured over type-declared; a " \
      "genuine same-class contradiction is an integrity incident, never " \
      "a silent merge."]],
    ["term-fw-10-03", "roll-up attestation",
     "signed attestation giving an aggregate over a committed traversal " \
     "set of child passports, verifiable without fetching every member " \
     "of the set",
     []],
    ["term-fw-10-04", "traversal set",
     "committed, hash-identified set of passport versions over which a " \
     "roll-up attestation or a graph traversal is computed",
     []],
    ["term-fw-10-05", "edge segment",
     "part of the event-sourced record of a subject that originates on " \
     "the subject's own device and is published through device " \
     "commitments",
     ["The device is a tier of the passport system, not a client; it " \
      "commits now and reveals later, but never contradicts."]],
    ["term-fw-10-06", "device commitment",
     "signature by a device-bound key over the hash of a prefix of the " \
     "device's local append-only event log, published so that later " \
     "disclosures are inclusion-consistent with past commitments",
     []],
    ["term-fw-10-07", "configuration vector",
     "exact combination of registered component options that, together " \
     "with a model, constitutes a configured product instance",
     []],
    ["term-fw-10-08", "type version",
     "versioned state of a type passport capturing hardware revisions " \
     "and type-declared facts, referenced exactly by the instance " \
     "passports derived from it",
     []],
    ["term-fw-10-09", "derived type",
     "new type resulting from a regulated modification of an existing " \
     "type, recorded as a derivation event in the identity lattice",
     []],
    ["term-dpp-0135", "dormant identifier",
     "identifier recorded at the finest available granularity for an " \
     "object class for which no passport regime yet exists, held as " \
     "issuance evidence for adoption by a future regime",
     ["When a future regime issues passports for the object class it " \
      "adopts the recorded dormant identifiers rather than minting new " \
      "ones, so that the installed base connects retroactively through " \
      "its build records.",
      "Inputs are recorded even when no passport exists behind them " \
      "yet; minting fresh identifiers would orphan the installed base."]],
    ["term-fw-10-11", "dormant-to-live adoption",
     "act of a future passport regime of issuing passports by adopting " \
     "the identifiers already recorded as dormant for the object class, " \
     "rather than minting new ones",
     ["Adoption connects the installed base retroactively through its " \
      "build records; minting fresh identifiers would orphan it."]],
  ],
  "03-11-fw-stamps.adoc" => [
    ["term-dpp-0128", "stamp",
     "lens-scoped attestation consisting of an attester signature over " \
     "the subject, the subject state commitment, the lens identity and " \
     "version, the mode (live or snapshot), a verdict with coverage " \
     "report, and log-anchored time",
     ["Stamps accrete append-only and are valid under the stamper's " \
      "lens regardless of the issuer's.",
      "Jurisdiction stamps on a foreign-issued passport correspond to " \
      "visas; entry and exit stamps correspond to verifier custody " \
      "events.",
      "Stamps may carry quantity context, inherited by downstream " \
      "transformations."]],
    ["term-fw-11-02", "lens-scoped attestation",
     "attestation whose validity is defined by, and only by, the " \
     "profile under which it was issued",
     ["A stamp is the signed form of a lens-scoped attestation."]],
    ["term-dpp-0130", "derived passport",
     "passport issued as the output of a transformation event by an " \
     "actor accredited for the regulated claims it contains, " \
     "hash-linking its input passports",
     ["Only accredited actors may issue derived passports for regulated " \
      "claims.",
      "Children of a split carry a derived-from reference and quantity " \
      "carve-outs, with the sum of children not exceeding the parent " \
      "(remainder semantics)."]],
    ["term-dpp-0129", "transformation event",
     "typed event in the provenance directed acyclic graph that records " \
     "the split of one passport into many, or the combination or " \
     "transformation of many passports into one",
     ["The output issuance event carries input references of passport, " \
      "quantity and as-of state hash, so the new passport hash-links " \
      "its sources.",
      "Quantities resulting from a transformation are new measured " \
      "facts with provenance \"computed by transformation event\", " \
      "never copies; mass balance is auditable as input minus output " \
      "equals loss.",
      "Inputs transition to consumed or transformed status: historical, " \
      "still verifiable, still needed for as-of queries."]],
    ["term-fw-11-05", "inputReference",
     "record in the issuance event of a derived passport naming an " \
     "input passport, the quantity consumed and the as-of state hash " \
     "under which it was taken",
     ["The new passport hash-links its sources, so that the provenance " \
      "graph is reconstructable without trusting the issuing actor " \
      "alone."]],
    ["term-fw-11-06", "quantity carve-out",
     "recorded allocation of input quantity to an output of a split " \
     "transformation, such that the sum of the child quantities does " \
     "not exceed the parent",
     []],
    ["term-fw-11-07", "mass balance accounting",
     "bookkeeping over transformation events in which inputs and " \
     "outputs of a specified characteristic are reconciled per period, " \
     "with losses and taint carried explicitly",
     ["Mass balance accounting applies a mass balance model (3.7.1) to " \
      "a set of transformation events."]],
    ["term-fw-11-08", "consumed passport",
     "input passport that has reached the consumed or transformed state " \
     "in a transformation event, retaining historical verifiability " \
     "for as-of queries",
     []],
    ["term-fw-11-09", "blind provenance",
     "attestation of input provenance issued by a notified or accredited " \
     "body that withholds the raw input identities behind its own " \
     "attestation, used where commercial confidentiality demands it",
     []],
    ["term-fw-11-10", "jurisdiction stamp",
     "stamp issued under a jurisdiction profile on a passport issued " \
     "under another jurisdiction, recording that the stamping " \
     "jurisdiction's requirements were assessed",
     ["The colloquial designation of a jurisdiction stamp on a foreign-" \
      "issued passport is \"visa\"; entry and exit stamps are the " \
      "verifier's custody events."]],
  ],
  "03-12-fw-characteristic.adoc" => [
    ["term-dpp-0125", "characteristic profile",
     "profile that attaches by predicate on digital twin facts, such as " \
     "age, material content, heritage status or market status, rather " \
     "than by law-of-place or industry",
     ["Characteristic profiles split into regulatory-triggered profiles " \
      "(for example CITES species content, cultural-goods import " \
      "controls, art-market due diligence, conflict-minerals origin) " \
      "and voluntary value profiles (for example provenance and " \
      "grading for antiques and collectibles).",
      "Predicate triggers include time predicates: an object becoming " \
      "older than a given age is a clock-fired applicability event " \
      "handled by the dated-binding machinery."]],
    ["term-dpp-0141", "trigger predicate",
     "declared component of a profile stating the conditions under " \
     "which the profile applies, evaluated against the facts of the " \
     "digital twin rather than against who declares them",
     ["Characteristic profiles attach by predicate on twin facts, " \
      "namely age, material content, heritage status, market status, " \
      "rather than by law-of-place or industry.",
      "Predicate triggers include time predicates: an object becoming " \
      "older than a given age is a clock-fired applicability event, " \
      "handled by the dated-binding machinery so that applicability " \
      "attaches without human declaration.",
      "The expression \"characteristic profile trigger\" denotes this " \
      "predicate as used by a characteristic profile and is folded " \
      "into this concept rather than recorded separately."]],
    ["term-fw-12-03", "commissioning",
     "issuance act by which a qualified attestor or registrar " \
     "establishes the identity of an object that predates or lies " \
     "outside a manufacturer-issued regime, recording the first " \
     "sighting in the event log",
     []],
    ["term-fw-12-04", "qualified attestor",
     "actor accredited under a profile's trust list to commission " \
     "identities or to attest attributes of orphan objects, such as an " \
     "auction house, authentication board or registrar",
     []],
    ["term-fw-12-05", "attribution",
     "expert statement assigning an object to a creator, workshop or " \
     "period, recorded as a competing fact with provenance rather than " \
     "merged with other attributions",
     []],
    ["term-fw-12-06", "provenance gap",
     "explicitly recorded interval in a subject's custody or provenance " \
     "chain for which no evidence exists",
     ["A provenance gap is data, not an error; it is honestly " \
      "representable in the event-sourced record."]],
    ["term-fw-12-07", "condition report",
     "dated, signed, profile-scoped assessment of the physical condition " \
     "of an object",
     []],
    ["term-fw-12-08", "restitution flag",
     "authority-attached marker on a passport recording a claim over " \
     "title, such as looting, dispossession or colonial taking, " \
     "propagated as a graph event without rewriting history",
     []],
  ],
  "03-13-fw-capability.adoc" => [
    ["term-fw-13-01", "capability class",
     "classification of a subject by its ability to participate in its " \
     "own record: silent, passive-auth, logged-contact or connected",
     ["A profile's freshness and verification requirements shall be " \
      "satisfiable by the capability class of the subject; demanding " \
      "live freshness from a silent subject is an unsatisfiable profile."]],
    ["term-fw-13-02", "silent subject",
     "subject with no connectivity, keys or self-reporting, whose record " \
     "is reconstructed entirely from testimonies about it",
     []],
    ["term-fw-13-03", "passive-auth subject",
     "subject carrying an authentication element, such as an NFC chip, " \
     "physically unclonable function or identity link, that attests " \
     "identity without recording events",
     []],
    ["term-fw-13-04", "logged-contact subject",
     "subject that records events locally and discloses them on " \
     "physical contact, without communications capability",
     []],
    ["term-fw-13-05", "connected subject",
     "subject that self-reports under device keys and participates with " \
     "full edge segments",
     []],
    ["term-dpp-0132", "passive twin",
     "digital twin reconstructed from point-in-time attestations about " \
     "the object, sampled when the object visits an attestor, in which " \
     "truth is episodic and staleness between attestations is unbounded " \
     "and undetectable",
     ["Corresponds to capability classes S0 (silent, testimony-only) " \
      "and S1 (passive authentication).",
      "Trust rides entirely on attestor authority; the twin is " \
      "testimonial by default and sensorial by exception."]],
    ["term-dpp-0133", "active twin",
     "digital twin in which the object self-reports under device keys, " \
     "making truth near-continuous, freshness bounded and detectable, " \
     "and shifting the binding question from who saw the object to who " \
     "attests the sensor",
     ["Corresponds to capability classes S2 (logged contact) and S3 " \
      "(connected).",
      "Measurement validity becomes load-bearing: sensor calibration, " \
      "uncertainty of self-reported values and registered units; " \
      "health status is a derived verdict.",
      "Profiles declare, per data element, the required truth mode, " \
      "namely attest-sampled, self-committed, or both with precedence."]],
    ["term-dpp-0145", "truth mode",
     "declared per-data-element attribute of a profile stating which " \
     "truth source the element requires, namely attest-sampled, " \
     "self-committed, or both with a precedence rule",
     ["The passive twin (concept dpp-0132) supplies attest-sampled " \
      "truth and the active twin (concept dpp-0133) supplies self-" \
      "committed truth; both paradigms coexist permanently in the " \
      "framework.",
      "Precedence between a calibrated device measurement and an " \
      "attestor observation is itself a metrological hierarchy question.",
      "Freshness and verification requirements must be satisfiable by " \
      "the subject's capability class: demanding live freshness from " \
      "an S0 (silent) product is an unsatisfiable profile."]],
    ["term-fw-13-09", "service-center model",
     "arrangement in which a subject's state is sampled and attested " \
     "only when the subject visits an attestor, yielding episodic " \
     "truth and unbounded, undetectable staleness between attestations",
     []],
    ["term-fw-13-10", "self-testimony",
     "testimony class consisting of events asserted by the subject's " \
     "own device under device-bound keys",
     []],
    ["term-fw-13-11", "continuous conformity monitoring",
     "conformity mode in which requirements are re-judged against the " \
     "live state of the twin, rather than only at point-in-time " \
     "inspection",
     []],
    ["term-fw-13-12", "state of health",
     "derived verdict on the condition of a subject, computed by a " \
     "stated model from measured variables",
     ["The provenance of the computing model is itself governed " \
      "information; health status is not a raw fact."]],
    ["term-fw-13-13", "sensor attestation",
     "attestation binding a measured value to a registered sensor " \
     "identity, its calibration and its measurement uncertainty",
     []],
  ],
  "03-14-fw-relations.adoc" => [
    ["term-fw-14-01", "association",
     "typed, navigational passport relationship, such as compatibility, " \
     "supply or same-maker, carrying no lifecycle impact",
     []],
    ["term-dpp-0142", "installation",
     "typed structural relationship, and its event class, between a " \
     "parent passport and an installed child component, recorded with " \
     "method, slot identity, pairing, alterations, performer and time, " \
     "which makes an installed component a different legal object from " \
     "the standalone one",
     ["Schema: install(child, parent, method, slotId, pairing (none, " \
      "firmware, key or module), alterations, performedBy, at).",
      "Bidirectional parent knowledge is mandatory: the parent's " \
      "manifest lists children and the child's event log records its " \
      "installation interval (parent, slot, method), for recall " \
      "routing, scoped service access, ownership transfer and end-of-" \
      "life routing.",
      "Lifecycle coupling: warranty re-scope and service economics ride " \
      "the parent, and the part is no longer sellable as new; custody " \
      "transfer (concept dpp-0134) remains orthogonal, since ownership " \
      "changes while composition stays fixed.",
      "The recoverability of the binding (concept dpp-0143) determines " \
      "identity continuity: disassembly that restores a marketable " \
      "object with identity continuity is installation, while " \
      "dissolving identity is a transformation event (concept " \
      "dpp-0129). Part replacement is an uninstall followed by an " \
      "install, and regulated children keep their own passports " \
      "through it."]],
    ["term-fw-14-03", "membership",
     "temporal relationship between a passport and a group node, such " \
     "as a shipment, consignment, kit, fleet or recall set",
     []],
    ["term-fw-14-04", "group node",
     "queryable grouping of passports that receives a passport of its " \
     "own only when the group is itself placed on the market",
     []],
    ["term-fw-14-05", "binding strength",
     "declared permanence of an installation binding, ranging from " \
     "reversible fastening to destructive integration",
     []],
    ["term-fw-14-06", "slot identity",
     "parent-scoped identifier of an installation position by which an " \
     "installed child is re-identified within its parent",
     []],
    ["term-fw-14-07", "pairing",
     "recorded binding of a child to its parent context, by firmware, " \
     "key or module, that is re-established when a component is replaced",
     []],
    ["term-fw-14-08", "absorbed component",
     "input whose identity dissolves into its parent and is therefore " \
     "modelled as a transformation input rather than a live child, " \
     "recorded at the finest available granularity as dormant identifiers",
     []],
    ["term-dpp-0143", "recoverability",
     "declared property of an installation binding (concept dpp-0142) " \
     "stating whether and how the installed child can resume an " \
     "independent existence, taking one of the values restorable, " \
     "harvestable, destructive or absorbing",
     ["Restorable: the child resumes standalone life; harvestable: " \
      "recovered but altered, continuing with harvested status and " \
      "parent history (concept dpp-0144); destructive: the child ceases " \
      "and flows to a material passport through a transformation event " \
      "(concept dpp-0129); absorbing: identity dissolves into the " \
      "parent.",
      "Absorption is regime-temporal rather than permanent: absorbed " \
      "inputs are recorded at the finest available granularity as " \
      "dormant identifiers (concept dpp-0135), issuable by adoption " \
      "when a future regime requires passports for the object class.",
      "Carried in the EXPRESS core as part of the PassportLink " \
      "binding (method, recoverability)."]],
    ["term-dpp-0144", "harvested part",
     "component recovered from an installation (concept dpp-0142) in " \
     "the harvestable state of the recoverability spectrum (concept " \
     "dpp-0143), which continues to carry its own identity, harvested " \
     "status and the parent history accumulated during installation",
     ["Installation history is value-relevant provenance: a harvested " \
      "battery sold standalone carries its service interval and " \
      "removal reason, and the used-parts market runs on this.",
      "A harvested part is second-hand-once-removed: no longer " \
      "sellable as new, with warranty scope and service economics " \
      "that rode the parent during installation."]],
    ["term-dpp-0134", "custody transfer",
     "signed ceremony recording the transfer of responsibility for an " \
     "object between custodians, appended to the event chain by the " \
     "custodian and the counterparty, which extends and never " \
     "overwrites the trail across successive owners",
     ["Custody links are social and control edges, orthogonal to " \
      "structural composition: ownership changes while composition " \
      "stays fixed."]],
    ["term-fw-14-12", "custodian",
     "actor that currently holds the live event segment of a subject's " \
     "record and is authorized to append custody-relevant events to it",
     []],
  ],
  "03-15-fw-visibility.adoc" => [
    ["term-dpp-0136", "blind edge",
     "edge on a typed passport relationship whose existence and " \
     "endpoints are concealed from all observers, so that a child-to-" \
     "parent reference does not reveal where a thing is, such as a " \
     "household or a site",
     ["Edge visibility classes, namely public, restricted (role-" \
      "qualified), blind and escrowed, are declared on every " \
      "relationship; the installation schema (concept dpp-0142) " \
      "carries visibility as an edge class with escrow arrangement " \
      "(concept dpp-0137) and audiences.",
      "Blind is the default for consumer installations, because even " \
      "the object-to-household linkage is personal data requiring a " \
      "GDPR or PIPL legal basis per profile.",
      "Rationale: a traversable graph with entitled upstream observers " \
      "is surveillance infrastructure; post-sale visibility into " \
      "instance state is owner-push or authority-based, never maker-" \
      "pull."]],
    ["term-dpp-0137", "escrowed disclosure",
     "edge visibility arrangement in which information concealed by a " \
     "blind edge (concept dpp-0136) is deposited with a threshold " \
     "trustee and released only through a disclosure ceremony, " \
     "namely court, regulator or consent",
     ["The installation schema records escrow as none or trustee, " \
      "with declared audiences.",
      "An escrow envelope under a threshold trustee may optionally " \
      "accompany a proof of binding (concept dpp-0138), preserving " \
      "verifiability while full disclosure remains ceremonial."]],
    ["term-dpp-0138", "proof of binding",
     "salted cryptographic commitment to the parent, recorded in the " \
     "child's event log, by which a child satisfies the bidirectional " \
     "parent-knowledge requirement without disclosing the identity of " \
     "the parent",
     ["Proof of binding is distinct from knowledge of parent: " \
      "verifiable modes establish that the child is validly installed " \
      "in some parent under a given profile (warranty, compliance) " \
      "without revealing which parent; full disclosure occurs only by " \
      "ceremony.",
      "An optional escrow envelope under a threshold trustee (concept " \
      "dpp-0137) accompanies the commitment where future disclosure " \
      "must remain possible."]],
    ["term-dpp-0139", "enumeration resistance",
     "system property by which the passport system is verifiable " \
     "without being browsable: resolution is by identity only, " \
     "traversal requires per-edge rights, and no party, including any " \
     "registry, resolver network or log operator, can enumerate the " \
     "installed base of anything",
     ["Transparency logs anchor commitments (hashes), never facts, so " \
      "log operators cannot correlate edges; accumulator and blind-" \
      "membership proofs give valid-standing checks without revealing " \
      "which or where.",
      "Stated as design invariant I12, together with blind edges by " \
      "default where households or sites are revealed (concept " \
      "dpp-0136), proof of binding distinct from knowledge of parent " \
      "(concept dpp-0138), and predicate-based recall (concept " \
      "dpp-0140)."]],
    ["term-dpp-0140", "predicate-based recall",
     "recall scheme in which the recall set is never enumerated " \
     "centrally: the recall predicate is published, and each custodian " \
     "evaluates it locally against their own holdings, including dark " \
     "and defence holdings under national procedure, and acts",
     ["The manufacturer receives aggregates or nothing; there is no " \
      "traversal-push enumeration of the installed base.",
      "One of the mechanisms by which enumeration resistance (concept " \
      "dpp-0139) is maintained: recall propagation still notifies " \
      "custodians transitively, but through local predicate " \
      "evaluation rather than central construction of the recall set."]],
    ["term-fw-15-06", "owner-push disclosure",
     "disclosure of instance state initiated by the owner, such as a " \
     "warranty registration, as the default manufacturer-visibility " \
     "channel",
     ["A manufacturer-initiated pull of instance state is not a " \
      "channel of the framework; authority-based compulsion of " \
      "traversal is a separate, legal-basis-governed mechanism."]],
    ["term-fw-15-07", "dark identity",
     "identity that is resolvable only within a restricted resolution " \
     "domain, such as a national domain, and never enters the global " \
     "resolver",
     []],
    ["term-fw-15-08", "confidential profile",
     "registered profile whose register item is non-public and which " \
     "carries restricted resolution, edge-visibility and traversal " \
     "fields, used for defence and sovereignty configurations",
     []],
  ],
  "03-16-fw-federation.adoc" => [
    ["term-fw-16-01", "trust marker",
     "graded indicator attached to every element or event stating its " \
     "trust provenance: unsigned, self-declared, third-party attested, " \
     "multi-signed or log-anchored",
     ["Trust is graded, not mandated; profiles set minimum signing " \
      "per data class."]],
    ["term-fw-16-02", "master list",
     "globally multi-witnessed list of trust lists, co-signed by a " \
     "quorum of independent logs, by which verifiers cross-recognize " \
     "jurisdictional trust authorities",
     []],
    ["term-fw-16-03", "revocation window",
     "explicit start and end interval carried by a distrust " \
     "declaration, within which affected credentials are void and " \
     "outside which they are re-validated",
     ["The reason for revocation determines retroactivity: prospective " \
      "reasons preserve earlier as-of verifications; misissuance voids " \
      "validity from the beginning."]],
    ["term-fw-16-04", "three verification readings",
     "three legally distinct readings of a verification result, " \
     "namely evidentiary, current-state and cryptographic, each of " \
     "which a verdict states explicitly",
     ["The evidentiary reading asks what a diligent verifier could " \
      "know at the time; the current-state reading voids fraud from " \
      "the beginning; the cryptographic reading covers signature and " \
      "chain validity alone."]],
    ["term-fw-16-05", "freshness verdict",
     "explicit, displayable assessment of how current a served state " \
     "is relative to its declared freshness bound, degrading visibly " \
     "when data is stale or offline",
     []],
    ["term-fw-16-06", "coverage report",
     "statement accompanying a verdict enumerating which elements, " \
     "trust anchors and registry items the verification covered",
     []],
    ["term-fw-16-07", "discovery registry",
     "federated registry of record for passport services and " \
     "semantics, in which profile shapes, protocol bindings, " \
     "verification mechanisms and service endpoints are versioned, " \
     "signed, log-anchored items discoverable by any conforming " \
     "client",
     ["The registry holds descriptors of services and shapes, never " \
      "records of things."]],
    ["term-fw-16-08", "service descriptor",
     "signed registry item describing a service by operator identity " \
     "and credential, service class, endpoints, protocol binding, " \
     "jurisdiction, residency class, status and succession pointer",
     []],
    ["term-fw-16-09", "protocol binding",
     "registered specification of a wire grammar, media types, " \
     "version and conformance suite by which an interaction with a " \
     "service or a device is conducted",
     []],
    ["term-fw-16-10", "verification mechanism bundle",
     "assembled set of registered items naming the cryptographic " \
     "suite, trust framework, trust-list endpoints, revocation " \
     "mechanism and acceptance-policy template under which a client " \
     "verifies",
     []],
    ["term-fw-16-11", "listing gate",
     "registered predicate evaluated by a marketplace over passport " \
     "status and standing without holding passport data, admitting or " \
     "refusing listings",
     []],
    ["term-fw-16-12", "operator credential",
     "scoped, threshold-issued credential by which an operator signs " \
     "registry items and service attestations",
     ["Appends claiming a role outside the credential's scope degrade " \
      "the trust marker; they do not pass silently."]],
    ["term-fw-16-13", "onboarding ceremony",
     "threshold admission ceremony by which an operator joins the " \
     "service federation, or a trust authority joins the master list, " \
     "accepting continuity and succession obligations",
     []],
    ["term-fw-16-14", "read federation",
     "federation tier in which any party consumes the registry and " \
     "trust bundles without an admission ceremony",
     []],
    ["term-fw-16-15", "service federation",
     "federation tier in which operators register services under " \
     "signed descriptors and accept continuity and succession " \
     "obligations",
     []],
    ["term-fw-16-16", "trust federation",
     "federation tier in which trust authorities join the master " \
     "list by threshold admission and jurisdictional profiles cross-" \
     "recognize one another",
     []],
    ["term-fw-16-17", "seed bundle",
     "bootstrap set of registry endpoints and trust anchors with " \
     "which a conforming client first initializes, resolving the " \
     "circular dependence between registry discovery and trust",
     []],
    ["term-fw-16-18", "registry pinning",
     "binding of a passport manifest or a verdict to exact registry " \
     "items by item, version and hash, so that later registry " \
     "changes never alter what a past issuance must satisfy",
     []],
  ],
}

def build_framework_file(fname, header, entries)
  body = []
  body << "[heading=terms and definitions]"
  body << header
  body << ""
  entries.each do |anchor, term, defn, notes|
    body << "[[#{anchor}]]"
    body << "=== #{term}"
    body << ""
    body << esc(defn)
    body << ""
    notes.each do |n|
      next if n.to_s.empty?
      body << "NOTE: " + esc(n)
      body << ""
    end
  end
  File.write(File.join(OUT, fname),
             "// framework-defined entries (UniDPP) - generated, do not edit by hand\n" +
             body.join("\n"))
end

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main
  FileUtils.mkdir_p(OUT)
  concepts = load_concepts
  apply_edits(concepts)
  apply_lineage_additions(concepts)
  apply_merges!(concepts)

  SECTION_HEADERS.each do |fname, header, section|
    list = concepts.values.select { |d| d["section"] == section }
    build_section_file(fname, header, list)
  end

  FRAMEWORK_TERMS.each do |fname, entries|
    build_framework_file(fname,
                         # Reuse the dead agent's headings
                         case fname
                         when "03-8-fw-profiles.adoc" then "== Terms related to the framework: profiles, lenses and jurisdiction"
                         when "03-9-fw-projection.adoc" then "== Terms related to the framework: projection, composition and service tiers"
                         when "03-10-fw-lattice.adoc" then "== Terms related to the framework: provenance, identity lattice and edge segments"
                         when "03-11-fw-stamps.adoc" then "== Terms related to the framework: stamps and the transformation algebra"
                         when "03-12-fw-characteristic.adoc" then "== Terms related to the framework: characteristic profiles and orphan objects"
                         when "03-13-fw-capability.adoc" then "== Terms related to the framework: capability classes and digital twins"
                         when "03-14-fw-relations.adoc" then "== Terms related to the framework: passport relationship algebra"
                         when "03-15-fw-visibility.adoc" then "== Terms related to the framework: visibility and enumeration resistance"
                         when "03-16-fw-federation.adoc" then "== Terms related to the framework: trust semantics, degradation and federation"
                         end,
                         entries)
  end

  counts = SECTION_HEADERS.map { |f, _, s| [s, concepts.values.count { |d| d["section"] == s }] }.to_h
  framework_count = FRAMEWORK_TERMS.values.sum(&:length)
  total = concepts.values.length + framework_count
  puts JSON.pretty_generate({
    core: counts,
    core_total: concepts.values.length,
    framework_total: framework_count,
    document_total: total,
    merges_applied: MERGES.transform_values { |v| "#{v['into']} (prefer #{v['prefer']})" },
    additions: AWI_ADDITIONS.size,
    lineage_additions: LINEAGE_ADDITIONS.size,
  })
end

require "json"
main if $PROGRAM_NAME == __FILE__
