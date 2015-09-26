require 'rails_helper'

RSpec.describe("shared/_pagination", { type: :view }) do
  it "renders the activity page with links" do
    render({
      partial: "shared/pagination",
      locals: {
        links: {
          next: "/resource?page=2",
          previous: "/resource?page=0"
        }
      }
    })

    expect(rendered).to match(/more/i)
    expect(rendered).to match(%r{href="/resource\?page=2"})
    expect(rendered).to match(/previous/i)
    expect(rendered).to match(%r{href="/resource\?page=0"})
  end

  it "does not show more link when there is not another page" do
    render({
      partial: "shared/pagination",
      locals: {
        links: {
          next: nil,
          previous: "/resource?page=0"
        }
      }
    })

    expect(rendered).to_not match(/more/i)
    expect(rendered).to_not match(%r{href="/resource\?page=2"})
  end

  it "does not show previous link when there is not a previous page" do
    render({
      partial: "shared/pagination",
      locals: {
        links: {
          next: "/resource?page=2",
          previous: nil
        }
      }
    })

    expect(rendered).to_not match(/previous/i)
    expect(rendered).to_not match(%r{href="/resource\?page=0"})
  end
end
