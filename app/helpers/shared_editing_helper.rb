module SharedEditingHelper
  def editable_content(content, field: nil, tag: :div, css_class: "", &block)
    return capture(&block) unless user_signed_in?

    field_name = field || "content"
    content_type = content.class.name.underscore
    content_id = content.respond_to?(:id) ? content.id : content.key

    # Get the current value
    current_value = if content.class.name == "SiteSetting"
      content.value
    elsif content.respond_to?(field_name)
      value = content.send(field_name)
      value.is_a?(ActionText::RichText) ? value.to_s : value
    else
      ""
    end

    content_tag tag,
      class: "editable-content #{css_class} relative group",
      data: {
        content_type: content_type,
        content_id: content_id,
        field: field_name,
        original_value: current_value,
        controller: "shared-editing"
      } do
      content_tag(:div, class: "editable-display") do
        if block_given?
          capture(&block)
        else
          if content.class.name == "SiteSetting" && content.value_type == "boolean"
            content.value == "true" ? "Enabled" : "Disabled"
          elsif field_name == "content" && content.respond_to?(:content) && content.content.is_a?(ActionText::RichText)
            content.content
          else
            simple_format(current_value.to_s)
          end
        end
      end +

      content_tag(:div,
        class: "editable-controls absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity duration-200",
        data: { shared_editing_target: "controls" }
      ) do
        link_to "#",
          class: "edit-btn bg-indigo-600 hover:bg-indigo-700 text-white px-3 py-1 rounded-md text-sm font-medium shadow-sm transition-colors",
          data: { action: "shared-editing#startEditing" } do
          content_tag(:svg, class: "inline w-4 h-4 mr-1", fill: "none", stroke: "currentColor", viewBox: "0 0 24 24") do
            content_tag(:path, "", 'stroke-linecap': "round", 'stroke-linejoin': "round", 'stroke-width': "2", d: "M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z")
          end + "Edit"
        end
      end
    end
  end

  def enable_shared_editing?
    user_signed_in? && SiteSetting.get("shared_editing_enabled")
  end
end
