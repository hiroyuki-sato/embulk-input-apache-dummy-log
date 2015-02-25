module Embulk
  module Input

    class ApacheDummyLogInputPlugin < InputPlugin
      Plugin.register_input("apache-dummy-log", self)

      RECORDS = 5000
      HOSTS = RECORDS/4
      PAGES = RECORDS/4

      AGENT_LIST_STRING = <<END
Mozilla/5.0 (iPhone; CPU iPhone OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3
Mozilla/5.0 (iPad; CPU OS 5_0_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko) Version/5.1 Mobile/9A405 Safari/7534.48.3
Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)
Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)
Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0)
Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)
Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; Trident/5.0)
Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)
Mozilla/5.0 (Windows NT 6.1; WOW64; rv:10.0.1) Gecko/20100101 Firefox/10.0.1
Mozilla/5.0 (Windows NT 6.1; WOW64; rv:10.0.1) Gecko/20100101 Firefox/10.0.1
Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7
Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.7 (KHTML, like Gecko) Chrome/16.0.912.77 Safari/535.7
Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11
Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11
Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11
Mozilla/5.0 (Windows NT 6.0; rv:10.0.1) Gecko/20100101 Firefox/10.0.1
Mozilla/5.0 (Windows NT 6.0; rv:10.0.1) Gecko/20100101 Firefox/10.0.1
Mozilla/5.0 (Windows NT 6.0; rv:10.0.1) Gecko/20100101 Firefox/10.0.1
Mozilla/5.0 (Windows NT 6.0; rv:10.0.1) Gecko/20100101 Firefox/10.0.1
Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11
Mozilla/5.0 (Windows NT 6.0) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.56 Safari/535.11
Mozilla/5.0 (Windows NT 5.1) AppleWebKit/535.11 (KHTML, like Gecko) Chrome/17.0.963.46 Safari/535.11
Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1
Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1
Mozilla/5.0 (Macintosh; Intel Mac OS X 10.6; rv:9.0.1) Gecko/20100101 Firefox/9.0.1
Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; YTB730; GTB7.2; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; .NET4.0C; .NET4.0E; Media Center PC 6.0)
Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; YTB730; GTB7.2; EasyBits GO v1.0; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)
Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; WOW64; Trident/4.0; GTB7.2; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)
Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0; YTB730; SLCC2; .NET CLR 2.0.50727; .NET CLR 3.5.30729; .NET CLR 3.0.30729; Media Center PC 6.0; .NET4.0C)
Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.0; WOW64; Trident/4.0; GTB6; SLCC1; .NET CLR 2.0.50727; Media Center PC 5.0; .NET CLR 3.5.30729; .NET CLR 3.0.30618; .NET4.0C)
Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; YTB720; GTB7.2; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729)
Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 5.1; Trident/4.0; BTRS122159; GTB7.2; .NET CLR 1.1.4322; .NET CLR 2.0.50727; .NET CLR 3.0.04506.30; .NET CLR 3.0.4506.2152; .NET CLR 3.5.30729; BRI/2)
END
      AGENT_LIST = AGENT_LIST_STRING.split("\n")

      PAGE_CATEGORIES = %w[
books
books
books
electronics
electronics
electronics
electronics
electronics
electronics
software
software
software
software
games
games
games
office
office
cameras
computers
finance
giftcards
garden
health
music
sports
toys
networking
jewelry
]

      class Host
        def initialize
          @ip = "#{(grand(210)+20)/4*4}.#{(grand(210)+20)/3*3}.#{grand(210)+20}.#{grand(210)+20}"
          @agents = []
        end

        attr_reader :ip
        def grand(n)
          RANDOM.rand(n)
        end

        def agent
          if @agents.size == 4
            @agents[grand(4)]
          else
            agent = AGENT_LIST[grand(AGENT_LIST.size)]
            @agents << agent
            agent
          end
        end
      end


      class Page
        def grand(n)
          RANDOM.rand(n)
        end
        def initialize
          cate = PAGE_CATEGORIES[grand(PAGE_CATEGORIES.size)]
          item = grand(RECORDS)

          if grand(2) == 0
            w = [cate, PAGE_CATEGORIES[grand(PAGE_CATEGORIES.size)]]
          else
            w = [cate]
          end
          q = w.map {|k| k[0].upcase + k[1..-1] }.join('+')
          search_path = "/search/?c=#{q}"
          google_ref = "http://www.google.com/search?ie=UTF-8&q=google&sclient=psy-ab&q=#{q}&oq=#{q}&aq=f&aqi=g-vL1&aql=&pbx=1&bav=on.2,or.r_gc.r_pw.r_qf.,cf.osb&biw=#{grand(5000)}&bih=#{grand(600)}"

          case grand(12)
          when 0,1,2,3,4,5
            @path = "/category/#{cate}"
            @referers = [nil, nil, nil, nil, nil, nil, nil, google_ref]
            @method = 'GET'
            @code = 200

          when 6
            @path = "/category/#{cate}?from=#{grand(3)*10}"
            @referers = [search_path, "/category/#{cate}"]
            @method = 'GET'
            @code = 200

          when 7,8,9,10
            @path = "/item/#{cate}/#{item}"
            @referers = [search_path, search_path, google_ref, "/category/#{cate}"]
            @method = 'GET'
            if grand(100) == 0
              @code = 404
            else
              @code = 200
            end

          when 11
            @path = search_path
            @referers = [nil]
            @method = 'POST'
            @code = 200
          end

          @size = grand(100) + 40
        end

        attr_reader :path, :size, :method, :code

        def referer
          if grand(2) == 0
            @referers[grand(@referers.size)]
          end
        end
      end

      RANDOM = Random.new

      def self.transaction(config, &control)
        # configuration code:
        task = {
          "size" => config.param("size", :integer, default: 100),
        }

        columns = [
          Column.new(0, "remote_host",    :string),
          Column.new(1, "identity_check", :string),
          Column.new(2, "user",           :string),
          Column.new(3, "datetime",       :timestamp),
          Column.new(4, "method",         :string),
          Column.new(5, "path",           :string),
          Column.new(6, "protocol",       :string),
          Column.new(7, "status",         :long),
          Column.new(8, "size",           :long),
          Column.new(9, "referer",        :string),
          Column.new(10,"user_agent",     :string)
        ]

        resume(task, columns, 1, &control)
      end

      def self.resume(task, columns, count, &control)
        commit_reports = yield(task, columns, count)

        next_config_diff = {}
        return next_config_diff
      end

      def init
        # initialization code:
        @size = @task["size"]

        @ip = "#{(grand(210)+20)/4*4}.#{(grand(210)+20)/3*3}.#{grand(210)+20}.#{grand(210)+20}"
        @agents = []

        @pages = []
        @size.times do
          @pages << Page.new
        end

        @hosts = []
        HOSTS.times do
          @hosts << Host.new
        end

      end

      def grand(n)
        RANDOM.rand(n)
      end

      def run

        now = Time.now.to_i

        @size.times do
          now += grand(5)
          page = @pages[grand(@pages.size)]
          host = @hosts[grand(@hosts.size)]
          record = [
            host.ip,     # remote_host
            '-',         # identity_check
            '-',         # user
            Time.new,    # datetime
            page.method, # method
            page.path,   # path
            'HTTP/1.1',  # protocol
            grand(10000) == 0 ? 500 : page.code, # status
            page.size,   # page.size
            (grand(2) == 0 ? @pages[grand(@pages.size)].path : page.referer) || '-', # referer
            host.agent,  # agent
          ]
          page_builder.add(record)
        end

        page_builder.finish

        commit_report = {}
        return commit_report
      end


    end
  end
end
