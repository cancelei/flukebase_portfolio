import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["display", "form", "editBtn"]
  static values = { 
    contentType: String, 
    contentId: String, 
    field: String,
    originalValue: String
  }

  connect() {
    this.setupEditableContent()
    console.log('Shared editing controller connected')
  }

  setupEditableContent() {
    // Show edit controls on hover
    this.element.addEventListener('mouseenter', () => {
      this.showEditControls()
    })

    this.element.addEventListener('mouseleave', () => {
      this.hideEditControls()
    })

    // Handle edit button click
    const editBtn = this.element.querySelector('.edit-btn')
    if (editBtn) {
      editBtn.addEventListener('click', (e) => {
        e.preventDefault()
        e.stopPropagation()
        this.startEditing()
      })
    }
  }

  showEditControls() {
    const controls = this.element.querySelector('.editable-controls')
    if (controls) {
      controls.classList.remove('hidden')
    }
  }

  hideEditControls() {
    const controls = this.element.querySelector('.editable-controls')
    if (controls && !this.element.querySelector('.inline-editor-form')) {
      controls.classList.add('hidden')
    }
  }

  async startEditing() {
    // Prevent multiple forms from opening
    if (this.element.querySelector('.inline-editor-form')) {
      console.log('Edit form already open for this field')
      return
    }

    console.log('Starting edit for:', this.contentTypeValue, this.contentIdValue, this.fieldValue)
    
    try {
      const params = new URLSearchParams({
        content_type: this.contentTypeValue.toLowerCase().replace(/([A-Z])/g, '_$1').toLowerCase(),
        content_id: this.contentIdValue,
        field: this.fieldValue
      })
      
      const response = await fetch(`/shared_editing/edit?${params}`, {
        method: 'GET',
        headers: {
          'Accept': 'text/html',
          'X-CSRF-Token': this.getCSRFToken()
        }
      })

      if (response.ok) {
        const html = await response.text()
        this.showEditForm(html)
      } else {
        console.error('Failed to load edit form:', response.status)
        this.showError('Failed to load edit form')
      }
    } catch (error) {
      console.error('Error loading edit form:', error)
      this.showError('Error loading edit form: ' + error.message)
    }
  }

  showEditForm(html) {
    const display = this.element.querySelector('.editable-display')
    const controls = this.element.querySelector('.editable-controls')
    
    if (display) display.style.display = 'none'
    if (controls) controls.classList.add('hidden')

    // Create form container
    const formContainer = document.createElement('div')
    formContainer.innerHTML = html
    formContainer.className = 'editable-form-container bg-white p-4 rounded-lg shadow-lg border border-gray-200'
    
    this.element.appendChild(formContainer)

    // Setup form event listeners
    this.setupFormListeners(formContainer)
  }

  setupFormListeners(formContainer) {
    const saveBtn = formContainer.querySelector('.inline-editor-save')
    const cancelBtn = formContainer.querySelector('.inline-editor-cancel')
    const input = formContainer.querySelector('.inline-editor-input, .inline-editor-textarea, .inline-editor-rich-text, .inline-editor-checkbox')

    if (saveBtn) {
      saveBtn.addEventListener('click', () => this.saveContent(formContainer, input))
    }

    if (cancelBtn) {
      cancelBtn.addEventListener('click', () => this.cancelEditing(formContainer))
    }

    // Save on Enter key (except for textareas and rich text)
    if (input && !input.classList.contains('inline-editor-textarea') && !input.classList.contains('inline-editor-rich-text')) {
      input.addEventListener('keydown', (e) => {
        if (e.key === 'Enter') {
          e.preventDefault()
          this.saveContent(formContainer, input)
        } else if (e.key === 'Escape') {
          this.cancelEditing(formContainer)
        }
      })
    }

    // Auto-focus the input
    if (input) {
      input.focus()
      if (input.type === 'text' || input.tagName === 'TEXTAREA') {
        input.select()
      }
    }
  }

  async saveContent(formContainer, input) {
    if (!input) return

    // Disable save button and show loading state
    const saveBtn = formContainer.querySelector('.inline-editor-save')
    const originalText = saveBtn ? saveBtn.textContent : 'Save'
    if (saveBtn) {
      saveBtn.textContent = 'Saving...'
      saveBtn.disabled = true
    }

    let value
    if (input.classList.contains('inline-editor-checkbox')) {
      value = input.checked
    } else if (input.classList.contains('inline-editor-rich-text')) {
      // For Trix editor, get the content from the editor
      const trixEditor = input.editor
      value = trixEditor ? trixEditor.getDocument().toString() : input.value
    } else {
      value = input.value
    }

    try {
      const response = await fetch('/shared_editing/update', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-CSRF-Token': this.getCSRFToken()
        },
        body: JSON.stringify({
          content_type: this.contentTypeValue,
          content_id: this.contentIdValue,
          field: this.fieldValue,
          value: value
        })
      })

      const data = await response.json()

      if (saveBtn) {
        saveBtn.textContent = originalText
        saveBtn.disabled = false
      }

      if (data.success) {
        this.updateDisplay(data.content)
        this.cancelEditing(formContainer)
        this.showSuccess(data.message)
      } else {
        console.error('Save failed:', data.errors)
        this.showError(data.errors ? data.errors.join(', ') : 'Failed to save changes')
      }
    } catch (error) {
      if (saveBtn) {
        saveBtn.textContent = originalText
        saveBtn.disabled = false
      }
      console.error('Save error:', error)
      this.showError('Error saving changes: ' + error.message)
    }
  }

  updateDisplay(newContent) {
    const display = this.element.querySelector('.editable-display')
    if (display) {
      if (this.fieldValue === 'content') {
        // Preserve HTML formatting for rich content
        display.innerHTML = newContent
      } else {
        display.textContent = newContent
      }
    }
  }

  formatContent(content) {
    if (typeof content === 'boolean') {
      return content ? 'Enabled' : 'Disabled'
    }
    return content.toString().replace(/\n/g, '<br>')
  }

  cancelEditing(formContainer) {
    if (formContainer) {
      formContainer.remove()
    }
    if (this.hasDisplayTarget) {
      this.displayTarget.style.display = "block"
    }
  }

  showSuccess(message) {
    this.showNotification(message, 'success')
  }

  showError(message) {
    this.showNotification(message, 'error')
  }

  showNotification(message, type) {
    // Create notification element
    const notification = document.createElement('div')
    notification.className = `fixed top-4 right-4 p-4 rounded-md shadow-lg z-50 ${
      type === 'success' 
        ? 'bg-green-100 text-green-800 border border-green-200' 
        : 'bg-red-100 text-red-800 border border-red-200'
    }`
    
    notification.innerHTML = `
      <div class="flex">
        <div class="flex-shrink-0">
          ${type === 'success' ? 
            '<svg class="h-5 w-5 text-green-400" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm3.707-9.293a1 1 0 00-1.414-1.414L9 10.586 7.707 9.293a1 1 0 00-1.414 1.414l2 2a1 1 0 001.414 0l4-4z" clip-rule="evenodd"></path></svg>' :
            '<svg class="h-5 w-5 text-red-400" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z" clip-rule="evenodd"></path></svg>'
          }
        </div>
        <div class="ml-3">
          <p class="text-sm font-medium">${message}</p>
        </div>
        <div class="ml-auto pl-3">
          <button onclick="this.parentElement.parentElement.parentElement.remove()" class="inline-flex rounded-md p-1.5 hover:bg-gray-100 focus:outline-none">
            <svg class="h-5 w-5" fill="currentColor" viewBox="0 0 20 20"><path fill-rule="evenodd" d="M4.293 4.293a1 1 0 011.414 0L10 8.586l4.293-4.293a1 1 0 111.414 1.414L11.414 10l4.293 4.293a1 1 0 01-1.414 1.414L10 11.414l-4.293 4.293a1 1 0 01-1.414-1.414L8.586 10 4.293 5.707a1 1 0 010-1.414z" clip-rule="evenodd"></path></svg>
          </button>
        </div>
      </div>
    `
    
    document.body.appendChild(notification)
    
    // Auto-remove after 5 seconds
    setTimeout(() => {
      if (notification.parentElement) {
        notification.remove()
      }
    }, 5000)
  }

  getCSRFToken() {
    const token = document.querySelector('[name="csrf-token"]')
    return token ? token.content : ''
  }
}
