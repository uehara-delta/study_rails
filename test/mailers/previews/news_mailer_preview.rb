# Preview all emails at http://localhost:3000/rails/mailers/news_mailer
class NewsMailerPreview < ActionMailer::Preview
  def daily_news
    NewsMailer.daily(DateTime.now)
  end
end
