class NewsletterWorkerJob
  include Sidekiq::Job

  def perform(post_id)
    # Find the post by ID
    post = Post.find(post_id)

    # Get all subscribers
    subscribers = Subscription.where(subscribed: true).pluck(:email)

    # Send the newsletter email to each subscriber
    subscribers.each do |subscriber_email|
      NewsletterMailer.new_article(post, subscriber_email).deliver_later
    end
  end
end
