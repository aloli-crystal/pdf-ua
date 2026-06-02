module PDF
  module UA
    # A `PDF::Document` pre-configured for PDF/UA-1 that validates
    # itself before writing.
    #
    # On construction it runs `PDF::UA.configure` (pdfuaid + display
    # doc title). On `write`/`save`, in the default strict mode, it
    # raises `ConformanceError` if any document-level accessibility
    # precondition is unmet, so an inaccessible file never reaches
    # disk silently.
    #
    # Composes with `pdf-a` : configure the same document for both
    # profiles to produce an archival *and* accessible PDF.
    class Document < PDF::Document
      property? strict : Bool

      def initialize(@strict : Bool = true)
        super()
        PDF::UA.configure(self)
      end

      def write(io : IO) : Nil
        violations = PDF::UA.violations(self)
        if @strict && !violations.empty?
          raise ConformanceError.new(violations)
        end
        super(io)
      end
    end

    # Raised by `PDF::UA::Document#write` in strict mode when the
    # document fails its PDF/UA-1 checks.
    class ConformanceError < Exception
      getter violations : Array(Violation)

      def initialize(@violations : Array(Violation))
        super(build_message)
      end

      private def build_message : String
        String.build do |io|
          io << "PDF/UA-1 conformance failed (" << @violations.size
          io << " violation(s)):\n"
          @violations.each { |v| io << "  - " << v.to_s << "\n" }
        end
      end
    end
  end
end
