require "../spec_helper"

# https://gitlab.com/arctic-fox/spectator/-/issues/80

class Item
end

class ItemUser
  @item = Item.new

  def item
    @item
  end
end

Spectator.describe "test1" do
  it "without mock" do
    item_user = ItemUser.new
    item = item_user.item
    item == item
  end
end

Spectator.describe "test2" do
  mock Item do
  end

  it "without mock" do
  end
end
