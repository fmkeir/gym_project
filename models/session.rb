require('date')
require_relative('../db/sql_runner')

class Session
  attr_accessor :type, :trainer, :room_id, :start_time
  attr_reader :id

  def initialize(options)
    @id = options["id"].to_i if options["id"]
    @type = options["type"]
    @trainer = options["trainer"]
    @room_id = options["room_id"].to_i
    @start_time = options["start_time"]
    @duration = options["duration"].to_i
  end

  def enough_space?()
    return members().count() < capacity()
  end

  def start_time_decimal()
    date_object = DateTime.parse(@start_time)
    return date_object.hour + date_object.minute.to_f/60
  end

  def save()
    sql = "INSERT INTO sessions
    (type, trainer, room_id, start_time, duration)
    VALUES
    ($1, $2, $3, $4, $5)
    RETURNING id"
    values = [@type, @trainer, @room_id, @start_time, @duration]
    @id = SqlRunner.run(sql, values)[0]["id"].to_i
  end

  def update()
    sql = "UPDATE sessions
    SET (type, trainer, room_id)
    = ($1, $2, $3)
    WHERE id = $4"
    values = [@type, @trainer, @room_id, @id]
    SqlRunner.run(sql, values)
  end

  def delete()
    sql = "DELETE FROM sessions WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def members()
    sql = "SELECT members.* FROM members
    INNER JOIN bookings
    ON bookings.member_id = members.id
    WHERE bookings.session_id = $1"
    values = [@id]
    return  SqlRunner.run(sql, values).map {|member| Member.new(member)}
  end

  def capacity()
    sql = "SELECT capacity FROM rooms WHERE id = $1"
    values = [@room_id]
    return SqlRunner.run(sql, values)[0]["capacity"].to_i
  end

  def self.all()
    sql = "SELECT * FROM sessions"
    return SqlRunner.run(sql).map {|session| Session.new(session)}
  end

  def self.delete_all()
    sql = "DELETE FROM sessions"
    SqlRunner.run(sql)
  end

  def self.find(id)
    sql = "SELECT * FROM sessions WHERE id = $1"
    values = [id]
    return Session.new(SqlRunner.run(sql, values)[0])
  end
end
