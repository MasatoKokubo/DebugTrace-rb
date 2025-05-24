# frozen_string_literal: false
# (C) 2025 Masato Kokubo

class Contact
  attr_reader :first_name, :last_name, :birthday
  def initialize(first_name, last_name, birthday)
    @first_name = first_name
    @last_name = last_name
    @birthday = birthday
  end
end
