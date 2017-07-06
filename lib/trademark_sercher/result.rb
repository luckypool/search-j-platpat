class TrademarkSearcher
  class Result
    ATTRIBUTES = %i{id name segments applicant applied_at registrated_at status}
    attr_reader *ATTRIBUTES

    def initialize(attributes)
      ATTRIBUTES.each do |key|
        value = attributes[key] || attributes[key.to_s]
        instance_variable_set("@#{key.to_s}", value)
      end
    end

    def to_hash
      keys   = ATTRIBUTES.map(&:to_s)
      values = keys.map { |k| instance_variable_get("@#{k}") }
      Hash[keys.zip(values)]
    end
  end
end
