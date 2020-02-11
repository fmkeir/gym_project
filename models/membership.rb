require('date')
require_relative('../db/sql_runner')

class Membership
  attr_accessor :type, :start_time, :end_time
  attr_reader :id

  def initialize(options)
    @id = options["id"].to_i if options["id"]
    @type = options["type"]
    @start_time = options["start_time"]
    @end_time = options["end_time"]
  end

  def time_decimal(time_to_convert)
    date_object = DateTime.parse(time_to_convert)
    return date_object.hour + date_object.minute.to_f/60
  end

  def start_time_decimal()
    return time_decimal(@start_time)
  end

  def end_time_decimal()
    return time_decimal(@end_time)
  end

  def save()
    sql = "INSERT INTO memberships
    (type, start_time, end_time)
    VALUES
    ($1, $2, $3)
    RETURNING id"
    values = [@type, @start_time, @end_time]
    @id = SqlRunner.run(sql, values)[0]["id"].to_i
  end

  def update()
    sql = "UPDATE memberships
    SET (type, start_time, end_time)
    = ($1, $2, $3)
    WHERE id = $4"
    values = [@type, @start_time, @end_time, @id]
    SqlRunner.run(sql, values)
  end

  def delete()
    sql = "DELETE FROM memberships WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def self.all()
    sql = "SELECT * FROM memberships"
    return SqlRunner.run(sql).map {|membership| Membership.new(membership)}
  end

  def self.delete_all()
    sql = "DELETE FROM memberships"
    SqlRunner.run(sql)
  end
end
