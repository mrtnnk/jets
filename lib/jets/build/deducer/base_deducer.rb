# Example Interface methods:
#
#   def process_type
#     "job"
#   end
#
#   def functions
#     [:perform]
#   end
class Jets::Build::Deducer
  class BaseDeducer
    attr_reader :path
    def initialize(path)
      @path = path
      require_application_code
    end

    def require_application_code
      # require "app/controllers/application_controller"
      # require "app/job/application_job"
      require "#{Jets.root}app/#{process_type.pluralize}/application_#{process_type}"
    end

    # PostsController
    def class_name
      @path.sub(%r{app/(\w+)/},'').sub('.rb','').classify
    end

    # This gets called in the node shim js template
    def handler_for(method)
      # process_type: controller or job
      regexp = Regexp.new("#{process_type.camelize}$")
      # module_name: posts (controller) or sleep (job)
      module_name = class_name.sub(regexp, '').underscore
      "handlers/#{process_type.pluralize}/#{module_name}.#{method}"
    end

    # Example return: "handlers/controllers/posts.js"
    def js_path
      @path.sub("app", "handlers").sub("_#{process_type}.rb", ".js")
    end

    # Used to show user where the generated files gets written to.
    # Example return: "/tmp/jets_build/templates/proj-dev-posts-controller.yml"
    def cfn_path
      stack_name = File.basename(@path, ".rb").dasherize
      stack_name = "#{Jets::Config.project_namespace}-#{stack_name}"
      "/tmp/jets_build/templates/#{stack_name}.yml"
    end
  end
end