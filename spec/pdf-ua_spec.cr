require "./spec_helper"

# Builds a fully PDF/UA-1-conformant (document-level) PDF.
private def conformant_doc : PDF::Document
  doc = PDF::Document.new
  doc.title = "Rapport accessible"
  doc.lang = "fr"
  PDF::UA.configure(doc)
  page = doc.page { |_| }
  doc.struct_tree do |tree|
    d = tree.add(PDF::Structure::Tag::DOCUMENT)
    p = d.add(PDF::Structure::Tag::P)
    page.tag(p) { page.font "Helvetica", size: 12; page.text "Bonjour", at: {72, 700} }
  end
  doc
end

describe PDF::UA do
  describe ".configure" do
    it "sets pdfuaid identification and DisplayDocTitle" do
      doc = PDF::Document.new
      PDF::UA.configure(doc)
      doc.pdfua_part.should eq(1)
      doc.display_doc_title.should be_true
    end
  end

  describe ".violations" do
    it "flags every missing precondition on a bare document" do
      doc = PDF::Document.new
      codes = PDF::UA.violations(doc).map(&.code)
      codes.should contain(:not_tagged)
      codes.should contain(:missing_lang)
      codes.should contain(:missing_title)
      codes.should contain(:missing_pdfuaid)
      codes.should contain(:display_doc_title_off)
    end

    it "returns no document-level violations for a conformant doc" do
      PDF::UA.violations(conformant_doc).should be_empty
      PDF::UA.conformant?(conformant_doc).should be_true
    end

    it "flags a tagged doc that lacks a language" do
      doc = PDF::Document.new
      doc.title = "T"
      PDF::UA.configure(doc)
      page = doc.page { |_| }
      doc.struct_tree do |tree|
        d = tree.add(PDF::Structure::Tag::DOCUMENT)
        p = d.add(PDF::Structure::Tag::P)
        page.tag(p) { page.font "Helvetica", size: 12; page.text "x", at: {72, 700} }
      end
      PDF::UA.violations(doc).map(&.code).should contain(:missing_lang)
    end
  end

  describe "PDF::UA::Document" do
    it "raises ConformanceError on save when preconditions are unmet (strict)" do
      doc = PDF::UA::Document.new
      doc.page { |_| } # no title, no lang, not tagged
      expect_raises(PDF::UA::ConformanceError, /Tagged PDF|language|title/) do
        doc.to_slice
      end
    end

    it "writes successfully when fully configured" do
      doc = PDF::UA::Document.new
      doc.title = "Accessible"
      doc.lang = "fr"
      page = doc.page { |_| }
      doc.struct_tree do |tree|
        d = tree.add(PDF::Structure::Tag::DOCUMENT)
        p = d.add(PDF::Structure::Tag::P)
        page.tag(p) { page.font "Helvetica", size: 12; page.text "ok", at: {72, 700} }
      end
      out = doc.to_slice.map(&.chr).join
      out.should contain("<pdfuaid:part>1</pdfuaid:part>")
      out.should contain("/DisplayDocTitle true")
      out.should contain("/StructTreeRoot")
    end

    it "does not raise in non-strict mode" do
      doc = PDF::UA::Document.new(strict: false)
      doc.page { |_| }
      doc.to_slice.size.should be > 0
    end
  end
end
