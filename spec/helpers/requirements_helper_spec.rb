require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the RequirementsHelper. For example:
#
# describe RequirementsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe(RequirementsHelper, { type: :helper }) do
  describe "#inject_links" do
    describe "finding links" do
      it "returns links without http" do
        expect(helper.inject_links("foo.com")).to match(%r{^<a href=\"http://foo.com\"})
      end

      it "returns links with http" do
        expect(helper.inject_links("http://foo.com")).to match(%r{^<a href=\"http://foo.com\"})
      end

      it "returns links with https" do
        expect(helper.inject_links("https://foo.com")).to match(%r{^<a href=\"https://foo.com\"})
      end

      it "does not link other protocols" do
        expect(helper.inject_links("ftp://foo.com")).to match(%r{^ftp://foo.com})
      end

      it "returns links for popular domains" do
        %w(com net ru org de jp uk br pl in it fr info au nl cn ir es gov).each do |tld|
          string  = "foo.#{tld}"
          expect(helper.inject_links(string)).to match(%r{^<a href=\"http://foo.#{tld}\"})
        end
      end

      it "does not return links for other domains" do
        expect(helper.inject_links("foo.xx")).to match(%r{^foo.xx$})
      end

      it "returns links with subdomains" do
        expect(helper.inject_links("www.deep.foo.com")).to match(%r{^<a href=\"http://www.deep.foo.com\"})
      end

      it "returns multiple links" do
        string = "http://foo.com and bar.com"
        expect(helper.inject_links(string)).to match(%r{^<a href=\"http://foo.com\"})
        expect(helper.inject_links(string)).to match(%r{and <a href=\"http://bar.com\"})
      end

      it "returns link with path" do
        expect(helper.inject_links("foo.com/bar?baz")).to match(%r{^<a href=\"http://foo.com/bar\?baz\"})
      end

      it "matches all valid domain names" do
        expect(helper.inject_links("f-Oo.com")).to match(%r{^<a href=\"http://f-Oo.com\"})
      end
    end

    it "returns links with domain as its content" do
      expect(helper.inject_links("https://foo.com/bar")).to match(%r{^<a href=\"https://foo.com\/bar\">foo.com})
    end

    it "returns links within content" do
      expect(helper.inject_links("find foo here foo.com")).to match(%r{find foo here <a href=\"http://foo.com\"})
    end
  end
end
