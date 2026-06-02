module PDF
  module UA
    # A single PDF/UA-1 conformance violation, traced to its ISO
    # 14289-1 (or WCAG-via-Matterhorn) clause.
    struct Violation
      getter code : Symbol
      getter message : String
      getter clause : String

      def initialize(@code : Symbol, @message : String, @clause : String)
      end

      def to_s(io : IO) : Nil
        io << "[" << @clause << "] " << @message
      end
    end
  end
end
