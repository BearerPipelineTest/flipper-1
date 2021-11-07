require 'helper'

RSpec.describe Flipper::Rules::All do
  let(:feature_name) { "search" }
  let(:plan_condition) {
    Flipper::Rules::Condition.new(
      {"type" => "Property", "value" => "plan"},
      {"type" => "Operator", "value" => "eq"},
      {"type" => "String", "value" => "basic"}
    )
  }
  let(:age_condition) {
    Flipper::Rules::Condition.new(
      {"type" => "Property", "value" => "age"},
      {"type" => "Operator", "value" => "gte"},
      {"type" => "Integer", "value" => 21}
    )
  }
  let(:any_rule) {
    Flipper::Rules::Any.new(
      plan_condition,
      age_condition
    )
  }
  let(:rule) {
    Flipper::Rules::All.new(
      plan_condition,
      age_condition
    )
  }

  describe "#initialize" do
    it "flattens rules" do
      instance = Flipper::Rules::Any.new([[plan_condition, age_condition]])
      expect(instance.rules).to eq([
        plan_condition,
        age_condition,
      ])
    end
  end

  describe ".build" do
    context "for Array of Hashes" do
      it "builds instance" do
        instance = Flipper::Rules::All.build([plan_condition.value, age_condition.value])
        expect(instance).to be_instance_of(Flipper::Rules::All)
        expect(instance.rules).to eq([
          plan_condition,
          age_condition,
        ])
      end
    end

    context "for nested Array of Hashes" do
      it "builds instance" do
        instance = Flipper::Rules::All.build([[plan_condition.value, age_condition.value]])
        expect(instance).to be_instance_of(Flipper::Rules::All)
        expect(instance.rules).to eq([
          plan_condition,
          age_condition,
        ])
      end
    end

    context "for Array with Any rule" do
      it "builds instance" do
        instance = Flipper::Rules::All.build(any_rule.value)
        expect(instance).to be_instance_of(Flipper::Rules::All)
        expect(instance.rules).to eq([any_rule])
      end
    end
  end

  describe "#all" do
    it "returns self" do
      expect(rule.all).to be(rule)
    end
  end

  describe "#any" do
    it "wraps self with any" do
      result = rule.any
      expect(result).to be_instance_of(Flipper::Rules::Any)
      expect(result.rules).to eq([rule])
    end
  end

  describe "#add" do
    context "with single rule" do
      it "returns new instance with rule added" do
        rule2 = Flipper::Rules::Condition.new(
          {"type" => "Property", "value" => "flipper_id"},
          {"type" => "Operator", "value" => "eq"},
          {"type" => "String", "value" => "User;2"}
        )
        result = rule.add rule2
        expect(result).not_to be(rule)
        expect(result.rules).to eq([rule.rules, rule2].flatten)
      end
    end

    context "with multiple rules" do
      it "returns new instance with rule added" do
        rule2 = Flipper::Rules::Condition.new(
          {"type" => "Property", "value" => "flipper_id"},
          {"type" => "Operator", "value" => "eq"},
          {"type" => "String", "value" => "User;2"}
        )
        rule3 = Flipper::Rules::Condition.new(
          {"type" => "Property", "value" => "flipper_id"},
          {"type" => "Operator", "value" => "eq"},
          {"type" => "String", "value" => "User;3"}
        )

        result = rule.add rule2, rule3
        expect(result).not_to be(rule)
        expect(result.rules).to eq([rule.rules, rule2, rule3].flatten)
      end
    end

    context "with array of rules" do
      it "returns new instance with rule added" do
        rule2 = Flipper::Rules::Condition.new(
          {"type" => "Property", "value" => "flipper_id"},
          {"type" => "Operator", "value" => "eq"},
          {"type" => "String", "value" => "User;2"}
        )
        rule3 = Flipper::Rules::Condition.new(
          {"type" => "Property", "value" => "flipper_id"},
          {"type" => "Operator", "value" => "eq"},
          {"type" => "String", "value" => "User;3"}
        )

        result = rule.add [rule2, rule3]
        expect(result).not_to be(rule)
        expect(result.rules).to eq([rule.rules, rule2, rule3].flatten)
      end
    end
  end

  describe "#remove" do
    context "with single rule" do
      it "returns new instance with rule removed" do
        result = rule.remove age_condition
        expect(result).not_to be(rule)
        expect(result.rules).to eq([plan_condition])
      end
    end

    context "with multiple rules" do
      it "returns new instance with rules removed" do
        result = rule.remove age_condition, plan_condition
        expect(result).not_to be(rule)
        expect(result.rules).to eq([])
      end
    end

    context "with array of rules" do
      it "returns new instance with rules removed" do
        result = rule.remove [age_condition, plan_condition]
        expect(result).not_to be(rule)
        expect(result.rules).to eq([])
      end
    end
  end

  describe "#value" do
    it "returns type and value" do
      expect(rule.value).to eq({
        "type" => "All",
        "value" => [
          plan_condition.value,
          age_condition.value,
        ],
      })
    end
  end

  describe "#eql?" do
    it "returns true if equal" do
      other_rule = Flipper::Rules::All.new(
        Flipper::Rules::Condition.new(
          {"type" => "Property", "value" => "plan"},
          {"type" => "Operator", "value" => "eq"},
          {"type" => "String", "value" => "basic"}
        ),
        Flipper::Rules::Condition.new(
          {"type" => "Property", "value" => "age"},
          {"type" => "Operator", "value" => "gte"},
          {"type" => "Integer", "value" => 21}
        )
      )
      expect(rule).to eql(other_rule)
      expect(rule == other_rule).to be(true)
    end

    it "returns false if not equal" do
      other_rule = Flipper::Rules::All.new(
        Flipper::Rules::Condition.new(
          {"type" => "Property", "value" => "plan"},
          {"type" => "Operator", "value" => "eq"},
          {"type" => "String", "value" => "premium"}
        ),
        Flipper::Rules::Condition.new(
          {"type" => "Property", "value" => "age"},
          {"type" => "Operator", "value" => "gte"},
          {"type" => "Integer", "value" => 21}
        )
      )
      expect(rule).not_to eql(other_rule)
      expect(rule == other_rule).to be(false)
    end

    it "returns false if not rule" do
      expect(rule).not_to eql(Object.new)
      expect(rule == Object.new).to be(false)
    end
  end

  describe "#matches?" do
    let(:rule) {
      Flipper::Rules::All.new(
        Flipper::Rules::Condition.new(
          {"type" => "Property", "value" => "plan"},
          {"type" => "Operator", "value" => "eq"},
          {"type" => "String", "value" => "basic"}
        ),
        Flipper::Rules::Condition.new(
          {"type" => "Property", "value" => "age"},
          {"type" => "Operator", "value" => "gte"},
          {"type" => "Integer", "value" => 21}
        )
      )
    }

    it "returns true when all conditions match" do
      actor = Flipper::Actor.new("User;1", "plan" => "basic", "age" => 21)
      expect(rule.matches?(feature_name, actor)).to be(true)
    end

    it "returns false when any condition does NOT match" do
      actor = Flipper::Actor.new("User;1", "plan" => "premium", "age" => 18)
      expect(rule.matches?(feature_name, actor)).to be(false)

      actor = Flipper::Actor.new("User;1", "plan" => "basic", "age" => 20)
      expect(rule.matches?(feature_name, actor)).to be(false)

      actor = Flipper::Actor.new("User;1", "plan" => "premium", "age" => 21)
      expect(rule.matches?(feature_name, actor)).to be(false)
    end
  end
end