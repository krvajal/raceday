class Racer

  attr_accessor :first_name, :last_name, :id, :gender, :group, :secs, :number

  def self.mongo_client
    Mongoid::Clients.default
  end

  def self.collection
    mongo_client[:racers]
  end

  def self.all(prototype = {}, sort = {:number => 1}, skip = 0, limit = nil)
    result = collection.find(prototype)
                 .projection({_id: true, number: true, first_name: true, last_name: true, gender: true, group: true, secs: true})
                 .sort(sort)
                 .skip(skip)

    result = result.limit(limit) if !limit.nil?
    result
  end

  def self.find(id)

    doc = collection.find(:_id => to_id(id))
              .projection({_id: true, number: true, first_name: true, last_name: true, gender: true, group: true, secs: true})
              .first
    return doc.nil? ? nil : Racer.new(doc)
  end

  def initialize(params = {})
    @id = params[:_id].nil? ? params[:id] : params[:_id].to_s
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @number = params[:number].to_i
    @gender = params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i
  end

  def save
    @id  = @id || BSON::ObjectId.new
    self.class.collection.insert_one(_id: @id, first_name: @first_name, last_name: @last_name, number: @number, gender: @gender, secs: @secs, group: @group)

  end

  def update params
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @number = params[:number].to_i
    @gender = params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i
    params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
    self.class.collection.find(_id: self.class.to_id(@id)).replace_one(params)
  end

  def destroy
    self.class.collection.find(number: @number).delete_one
  end

  def self.to_id id
    id.is_a?(String) ? BSON::ObjectId.from_string(id) : id
  end
end

