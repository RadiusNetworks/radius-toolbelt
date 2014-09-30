unless String.public_instance_methods.include? :strip_heredoc
  String.class_exec do # self is set to the String class
    def strip_heredoc
      leading_space = scan(/^[ \t]*(?=\S)/).min
      indent = leading_space ? leading_space.size : 0
      gsub(/^[ \t]{#{indent}}/, '')
    end
  end
end
