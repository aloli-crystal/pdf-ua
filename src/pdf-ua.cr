require "pdf"

# PDF/UA accessibility-profile layer on top of `aloli-crystal/pdf`.
#
# `pdf-ua` does not re-implement PDF generation : it *configures* a
# `PDF::Document` for ISO 14289-1 (PDF/UA-1) and *validates* the
# document-level accessibility preconditions the engine can satisfy.
# It builds directly on the Tagged PDF work of pdf's J2 milestone
# (logical structure tree, marked content, /Lang).
#
# It composes with `pdf-a` : a document may be configured for both
# PDF/A and PDF/UA (the common ALOLI archival-and-accessible target).
#
# ## Usage
#
# ```
# require "pdf-ua"
#
# pdf = PDF::UA::Document.new
# pdf.title = "Rapport accessible"
# pdf.lang = "fr"
#
# pdf.struct_tree do |tree|
#   doc = tree.add(PDF::Structure::Tag::DOCUMENT)
#   h1 = doc.add(PDF::Structure::Tag::H1, title: "Titre")
#   page = pdf.page { |_| }
#   pg.tag(h1) { page.text "Titre", at: {72, 760} }
# end
#
# pdf.save("accessible.pdf") # raises if a PDF/UA precondition fails
# ```
#
# ## Scope (palier 1)
#
# Document-level requirements : Tagged PDF marking, document language,
# title + DisplayDocTitle, pdfuaid identification. Per-element checks
# (every figure has /Alt, heading order, table headers, every content
# tagged or artifact) are layered in later paliers, and ultimately
# cross-checked by `pdf-validate` (J5).

require "./pdf-ua/version"
require "./pdf-ua/violation"
require "./pdf-ua/conformance"
require "./pdf-ua/document"
