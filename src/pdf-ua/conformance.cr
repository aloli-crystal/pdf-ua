module PDF
  module UA
    # Configures a `PDF::Document` for PDF/UA-1 and validates the
    # document-level accessibility preconditions.

    # Configures `doc` for PDF/UA-1 :
    # * declares the pdfuaid identification (`pdfua_part = 1`),
    # * turns on `display_doc_title` (title bar shows the document
    #   title, not the file name).
    #
    # The author still has to provide a document language (`doc.lang`),
    # a title (`doc.title`) and a tagged logical structure
    # (`doc.struct_tree`) — these can't be invented automatically.
    # `violations` checks they are present.
    #
    # Returns `doc` for chaining.
    def self.configure(doc : PDF::Document) : PDF::Document
      doc.pdfua_part = PART
      doc.display_doc_title = true
      doc
    end

    # Returns the list of detected PDF/UA-1 document-level violations.
    # An empty array means the document passes the *document-level*
    # accessibility checks this palier implements — it is NOT a full
    # ISO 14289-1 certificate (per-element checks come later; the
    # authoritative verdict is `pdf-validate`'s job, J5).
    def self.violations(doc : PDF::Document) : Array(Violation)
      list = [] of Violation

      # --- Tagged PDF required (ISO 14289-1 § 7.1) ---
      unless doc.tagged?
        list << Violation.new(
          :not_tagged,
          "A PDF/UA file must be a Tagged PDF (a non-empty logical " \
          "structure tree). Build one via doc.struct_tree.",
          "ISO 14289-1 § 7.1",
        )
      end

      # --- Document language (ISO 14289-1 § 7.2) ---
      if doc.lang.nil? || doc.lang.try(&.empty?)
        list << Violation.new(
          :missing_lang,
          "The document must declare a default natural language " \
          "(set doc.lang, e.g. \"fr\" or \"en-US\").",
          "ISO 14289-1 § 7.2",
        )
      end

      # --- Document title + DisplayDocTitle (ISO 14289-1 § 7.1) ---
      if doc.title.nil? || doc.title.try(&.empty?)
        list << Violation.new(
          :missing_title,
          "The document must have a title (set doc.title).",
          "ISO 14289-1 § 7.1",
        )
      end
      unless doc.display_doc_title
        list << Violation.new(
          :display_doc_title_off,
          "ViewerPreferences /DisplayDocTitle must be true so the " \
          "title bar shows the document title (call PDF::UA.configure).",
          "ISO 14289-1 § 7.1",
        )
      end

      # --- pdfuaid identification (ISO 14289-1 § 5 / Annex B) ---
      if doc.pdfua_part != PART
        list << Violation.new(
          :missing_pdfuaid,
          "Missing PDF/UA identification (XMP pdfuaid:part = 1). " \
          "Call PDF::UA.configure(doc).",
          "ISO 14289-1 § 5",
        )
      end

      list
    end

    # `true` if `doc` passes the document-level PDF/UA-1 checks.
    def self.conformant?(doc : PDF::Document) : Bool
      violations(doc).empty?
    end
  end
end
