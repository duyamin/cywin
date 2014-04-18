class Project < ActiveRecord::Base
  my_const_set('STAGES', [ 'IDEA', 'DEVELOPING', 'ONLINE', 'GAINED' ])
    
  validates :name, presence: true, uniqueness: true
  validates :oneword, presence: true
  #validates :stage, presence: true, inclusion: STAGES
  validates :description, presence: true

  #validates :logo, presence: true

  mount_uploader :logo, LogoUploader

  has_one :contact
  has_and_belongs_to_many :users, join_table: :members
  has_many :members, autosave: true
  
  # 创业需求
  has_many :money_requires
  has_many :person_requires

  # 关注人员
  has_many :stars

  scope :published, -> { where(published: true) }

  def add_owner( owner )
    add_user(owner, role: Member::FOUNDER, priv: 'owner')
  end
  
  # user 
  def owner
    self.users.where('members.priv' => 'owner').first
  end

  def member( user )
    self.members.where(user_id: user.id).first
  end

  def add_user( user, option={} )
    member = Member.new
    member.user = user
    member.priv = option[:priv] || 'viewer'
    member.role = option[:role]
    self.members << member
  end

  def members_but(user)
    self.members.where.not(user_id: user.id)
  end

  def complete_degree
    0.8
  end

  def opened_money_require
    self.money_requires.where.not(status: :closed).first
  end

  def history_money_requires
    self.money_requires.where(status: :closed).order(created_at: :desc)
  end
  
  # 所有投资人
  def investor_users
    money_require_ids = self.money_requires.collect { |m| m.id }
    investor_ids = Investment.where(money_require_id: money_require_ids).collect{ |m| m.investor_id }
    user_ids = Investor.where(id: investor_ids).collect{ |m| m.user_id }
    User.where(id: user_ids)
  end

  def publish
    #TODO 检查完成度
    self.published = true
    self.save
  end

  def published?
    self.published
  end

  def star_users
    user_ids = self.stars.collect { |m| m.user_id }
    User.where(id: user_ids)
  end
end
