actor Main
  new create(env: Env) =>
    let template = """
    Hello {{name}}
    You have just won {{value}} dollars!
    {{#in_ca}}
    Well, {{taxed_value}} dollars, after taxes.
    {{/in_ca}}
    {{^blarg}}
    You shouldn't see this
    {{/blarg}}
    {{#blarg}}
    You should see this
    {{/blarg}}
    {{= <% %> =}}
    <%^blarg%>
    You shouldn't see this either
    <%/blarg%>
    <%#blarg%>
    You should see this too
    <%/blarg%>
    <%= {{ }} =%>
    {{^blarg}}
    You shouldn't see this
    {{/blarg}}
    """

    let m = Mustache
    try
      m.template(template)?
      env.out.print(m.print_tokens())
    else
      env.err.print("Unable to parse template")
      env.err.print(m.err)
    end
