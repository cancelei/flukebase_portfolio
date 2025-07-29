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

    // Handle edit button click - find all edit buttons within this controller element
    const editBtns = this.element.querySelectorAll('.edit-btn')
    if (editBtns.length > 0) {
      editBtns.forEach(btn => {
        btn.addEventListener('click', (e) => {
          e.preventDefault()
          e.stopPropagation()
          this.startEditing()
        })
      })
    }
  }

  showEditControls() {
    const controls = this.element.querySelectorAll('.editable-controls')
    if (controls.length > 0) {
      controls.forEach(control => {
        control.classList.remove('hidden')
        control.style.opacity = '1'
      })
    }
  }

  hideEditControls() {
    const controls = this.element.querySelectorAll('.editable-controls')
    if (controls.length > 0 && !this.element.querySelector('.inline-editor-form')) {
      controls.forEach(control => {
        control.classList.add('hidden')
        control.style.opacity = '0'
      })
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
      // Format the content_type correctly - convert CamelCase to snake_case
      const contentType = this.contentTypeValue.replace(/([A-Z])/g, function(g) { return '_' + g.toLowerCase(); }).replace(/^_/, '')
      
      const params = new URLSearchParams({
        content_type: contentType,
        content_id: this.contentIdValue,
        field: this.fieldValue
      })
      
      console.log('Request params:', params.toString())
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
    const display = this.element.querySelector(':scope > .editable-display')
    const controls = this.element.querySelector(':scope > .editable-controls')
    
    if (display) display.style.display = 'none'
    if (controls) controls.classList.add('hidden')

    // Create form container
    const formContainer = document.createElement('div')
    formContainer.innerHTML = html
    formContainer.className = 'editable-form-container'
    
    this.element.appendChild(formContainer)

    // Setup form event listeners
    this.setupFormListeners(formContainer)
  }

  setupFormListeners(formContainer) {
    const saveBtn = formContainer.querySelector('.inline-editor-save')
    const cancelBtn = formContainer.querySelector('.inline-editor-cancel')
    const input = formContainer.querySelector('input[name="value"], textarea[name="value"]')
    const trixEditor = formContainer.querySelector('trix-editor')

    if (saveBtn) {
      saveBtn.addEventListener('click', () => this.saveContent(formContainer, input, trixEditor))
    }

    if (cancelBtn) {
      cancelBtn.addEventListener('click', () => this.cancelEditing(formContainer))
    }

    // Handle Trix editor
    if (trixEditor) {
      // Focus the Trix editor
      setTimeout(() => {
        trixEditor.focus()
      }, 100)

      // Handle keyboard shortcuts for Trix
      trixEditor.addEventListener('keydown', (e) => {
        if (e.key === 'Escape') {
          this.cancelEditing(formContainer)
        }
        // Ctrl/Cmd + Enter to save
        if ((e.ctrlKey || e.metaKey) && e.key === 'Enter') {
          e.preventDefault()
          this.saveContent(formContainer, input, trixEditor)
        }
      })
    } else {
      // Handle regular inputs
      // Save on Enter key (except for textareas)
      if (input && input.tagName !== 'TEXTAREA') {
        input.addEventListener('keydown', (e) => {
          if (e.key === 'Enter') {
            e.preventDefault()
            this.saveContent(formContainer, input, trixEditor)
          } else if (e.key === 'Escape') {
            this.cancelEditing(formContainer)
          }
        })
      }

      // Escape key for textareas
      if (input && input.tagName === 'TEXTAREA') {
        input.addEventListener('keydown', (e) => {
          if (e.key === 'Escape') {
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
  }

  async saveContent(formContainer, input, trixEditor) {
    // Disable save button and show loading state
    const saveBtn = formContainer.querySelector('.inline-editor-save')
    const originalText = saveBtn ? saveBtn.textContent : 'Save'
    if (saveBtn) {
      saveBtn.textContent = 'Saving...'
      saveBtn.disabled = true
    }

    let value
    if (trixEditor) {
      // Get HTML content from Trix editor properly
      try {
        // Method 1: Get HTML content from the Trix editor's document (proper way)
        if (trixEditor.editor && trixEditor.editor.getDocument) {
          value = trixEditor.editor.getDocument().toHTMLString()
        } else if (trixEditor.innerHTML) {
          // Method 2: Get innerHTML content directly
          value = trixEditor.innerHTML
        } else {
          // Method 3: Fallback - look for the associated input
          const associatedInput = document.querySelector(`input[id="${trixEditor.getAttribute('input')}"]`)
          if (associatedInput) {
            value = associatedInput.value
          } else {
            value = ''
          }
        }
      } catch (error) {
        console.error('Error getting Trix content:', error)
        // Final fallback - try to get from innerHTML or empty
        value = trixEditor.innerHTML || ''
      }
    } else if (input) {
      if (input.type === 'checkbox') {
        value = input.checked
      } else {
        value = input.value
      }
    } else {
      return
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
    const display = this.element.querySelector(':scope > .editable-display')
    if (display) {
      if (this.fieldValue === 'content') {
        // For rich content fields, update the inner content while preserving structure
        const contentElement = display.querySelector('.text-gray-700, .prose, h1, h2, h3, h4, h5, h6, p, div')
        if (contentElement) {
          contentElement.innerHTML = newContent
        } else {
          display.innerHTML = newContent
        }
      } else {
        // For title fields, update the text content of heading elements
        const titleElement = display.querySelector('h1, h2, h3, h4, h5, h6')
        if (titleElement) {
          titleElement.textContent = newContent
        } else {
          display.textContent = newContent
        }
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
    
    const display = this.element.querySelector(':scope > .editable-display')
    if (display) {
      display.style.display = 'block'
    }
    
    const controls = this.element.querySelector(':scope > .editable-controls')
    if (controls) {
      controls.classList.add('hidden')
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
