require 'test/unit'
require 'config/testing'
require 'crocoduck/job'


class JobTest < Test::Unit::TestCase
  def setup
    store = Crocoduck::Store.new
    store.remove({})
    store.insert({
      "_id" => 50000,
      "url" => "/tech-policy/news/2011/04/pickpocketing-or-voluntary-auctions-the-wireless-spectrum-standoff.ars",
    })
  end
  
  def test_job_creation
    job = Crocoduck::Job.init_with_id 50000
    assert_equal job.entry["url"], "/tech-policy/news/2011/04/pickpocketing-or-voluntary-auctions-the-wireless-spectrum-standoff.ars"
    job.entry.close
  end
  
  def test_job_perform
    job = Crocoduck::Job.perform 50000
  end
end
