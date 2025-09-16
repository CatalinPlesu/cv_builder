Rails.application.configure do
  # Use async adapter
  config.active_job.queue_adapter = :async

  # Configure async adapter limits
  if config.active_job.queue_adapter == :async
    require "concurrent"

    # Create a custom executor with limits
    # 1 thread for execution, max 500 jobs in queue
    Rails.application.config.after_initialize do
      ActiveJob::QueueAdapters::AsyncAdapter.class_eval do
        private

        def self.scheduler
          @scheduler ||= Concurrent::ThreadPoolExecutor.new(
            min_threads: 0,
            max_threads: 1,  # Only 1 job executing at a time
            max_queue: 500,  # Max 500 jobs in queue
            fallback_policy: :abort  # Reject new jobs if queue is full
          )
        end
      end
    end
  end
end
