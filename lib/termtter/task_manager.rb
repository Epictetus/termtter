module Termtter
  class TaskManager

    Interval = 1

    def initialize()
      @tasks = []
      @work = true
      @mutex = Mutex.new
    end

    # TODO: to thread safe
    def add_task(args = {}, &block)
      synchronize do
        @tasks << Task.new(args, &block)
      end
    end

    def run
      Thread.new do
        while @work
          step
          sleep Interval
        end
      end
    end

    def step
      pull_due_tasks().each do |task|
        begin
          task.execute
        rescue => e
          handle_error(e)
        end
      end
    end

    def stop
      @work = false
    end

    private

    # TODO: to thread safe
    def pull_due_tasks()
      synchronize do
        time_now = Time.now
        due_tasks = []
        @tasks.delete_if do |task|
          if task.exec_at <= time_now
            due_tasks << task
            if task.repeat_interval
              task.exec_at += task.repeat_interval
              false
            else
              true
            end
          else
            false
          end
        end
        return due_tasks
      end
    end

    def synchronize
      @mutex.synchronize {
        yield
      }
    end

  end
end
