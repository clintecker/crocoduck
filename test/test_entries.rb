require 'test/unit'
require 'config/development'
require 'crocoduck/entry'

class EntryTest < Test::Unit::TestCase
  def setup
    store = Crocoduck::Store.new
    store.remove({})
    store.insert({
      "_id" => 50000,
      "url" => "/tech-policy/news/2011/04/pickpocketing-or-voluntary-auctions-the-wireless-spectrum-standoff.ars",
    })
  end
  
  def test_entry_creation_property_access
    e = Crocoduck::Entry.new(50000)
    assert_equal e["url"], "/tech-policy/news/2011/04/pickpocketing-or-voluntary-auctions-the-wireless-spectrum-standoff.ars"
  end
end
