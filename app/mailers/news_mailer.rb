class NewsMailer < ApplicationMailer

  default from: "from@example.com"
  def daily(datetime)
    @delivered_at = datetime
    mail to: "to@example.com"
  end

end
