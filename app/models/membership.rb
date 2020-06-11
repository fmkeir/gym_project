require('date')
require_relative('../db/sql_runner')
require_relative('../helpers/datetime')
require_relative('../helpers/style')

class Membership
  attr_accessor :type, :start_time, :end_time
  attr_reader :id

  def initialize(options)
    @id = options["id"].to_i if options["id"]
    @type = options["type"]
    @start_time = options["start_time"]
    @end_time = options["end_time"]
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

  def type_styled()
    return titlecase_with_spaces(type())
  end

  def self.all()
    sql = "SELECT * FROM memberships ORDER BY (end_time - start_time) DESC"
    return SqlRunner.run(sql).map {|membership| Membership.new(membership)}
  end

  def self.delete_all()
    sql = "DELETE FROM memberships"
    SqlRunner.run(sql)
  end

  def self.find(id)
    sql = "SELECT * FROM memberships WHERE id = $1"
    values = [id]
    return Membership.new(SqlRunner.run(sql, values)[0])
  end
end
