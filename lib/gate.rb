# 改札口を表すクラスです。
#
# @example 梅田で180円の切符を購入して乗車し、庄内で降車する
#   ticket = Ticket.new(180)
#   umeda = Gate.new(:umeda)
#   shonai = Gate.new(:shonai)
#   umeda.enter(ticket)
#   shonai.exit(ticket) #=> true
#
# @example 梅田で150円の切符を購入して乗車し、庄内で降車する
#   ticket = Ticket.new(150)
#   umeda = Gate.new(:umeda)
#   shonai = Gate.new(:shonai)
#   umeda.enter(ticket)
#   shonai.exit(ticket) #=> false
class Gate
  # 駅の名前を返します。
  # @return [Symbol] 駅の名前
  attr_reader :name

  STATIONS = [
    :umeda,
    :juso,
    :shonai,
    :okamachi
  ]

  FARES = [
      nil,
      150,
      180,
      220
  ]

  # 改札口を初期化します。
  # @param name [Symbol] 駅の名前
  def initialize(name)
    @name = name
  end

  # 改札口から入場します。<br>
  # 切符には駅の名前が記録されます。
  # @param ticket [Ticket] 切符
  # @raise [AlreadyEnteredTicketError] すでに入場済みの切符を使った場合に発生します。
  def enter(ticket)
    raise AlreadyEnteredTicketError if ticket.from

    ticket.enter(self.name)
  end

  # 改札口から出場します。<br>
  # 切符の運賃が足りていればtrueを返し、切符を使用済みにします。
  # @param ticket [Ticket] 切符
  # @return [Boolean] 運賃が足りていればtrue、不足していればfalse
  # @raise [StaleTicketError] 使用済みの切符を使った場合に発生します。
  # @raise [NotEnteredTicketError] 未入場の切符を使った場合に発生します。
  # @raise [ExitSameStationError] 乗車駅と同じ駅で出場した場合に発生します。
  def exit(ticket)
    raise ExitSameStationError if ticket.from == self.name
    raise StaleTicketError if ticket.stale?
    ticket.mark_as_stale
    exitable?(ticket)
  end

  private

  def exitable?(ticket)
    from_index = STATIONS.index(ticket.from)
    to_index = STATIONS.index(self.name)
    fare = FARES[(from_index - to_index).abs]
    ticket.fee >= fare
  end
end
