import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["addForm", "experienceContainer", "experienceItem"]
  
  // Track the drop indicator element
  dropIndicator = null

  connect() {
    console.log('CV Page controller connected')
    this.setupScrollAnimations()
    this.setupDragAndDrop()
    
    // Create drop indicator element
    this.createDropIndicator()
  }
  
  // Create a drop indicator element that will show where the item will be dropped
  createDropIndicator() {
    this.dropIndicator = document.createElement('div')
    this.dropIndicator.className = 'drop-indicator hidden'
    this.dropIndicator.style.height = '3px'
    this.dropIndicator.style.backgroundColor = '#3b82f6' // blue-500
    this.dropIndicator.style.position = 'absolute'
    this.dropIndicator.style.left = '0'
    this.dropIndicator.style.right = '0'
    this.dropIndicator.style.zIndex = '50'
    this.dropIndicator.style.transition = 'transform 0.2s ease'
    this.dropIndicator.style.display = 'none'
    
    document.body.appendChild(this.dropIndicator)
  }
  
  // Debug method to log all targets
  logTargets() {
    console.log('Experience container:', this.experienceContainerTarget)
    console.log('Experience items:', this.experienceItemTargets)
    console.log('Add form:', this.addFormTarget)
  }

  toggleExperienceForm() {
    const form = this.addFormTarget
    
    if (form.classList.contains('hidden')) {
      // Show form with animation
      form.classList.remove('hidden')
      form.style.opacity = '0'
      form.style.transform = 'translateY(-20px)'
      
      // Animate in
      requestAnimationFrame(() => {
        form.style.transition = 'all 0.3s ease-out'
        form.style.opacity = '1'
        form.style.transform = 'translateY(0)'
      })
      
      // Focus the first input
      setTimeout(() => {
        const firstInput = form.querySelector('input[type="text"]')
        if (firstInput) firstInput.focus()
      }, 300)
      
      // Scroll to form
      form.scrollIntoView({ behavior: 'smooth', block: 'start' })
    } else {
      // Hide form with animation
      form.style.transition = 'all 0.3s ease-in'
      form.style.opacity = '0'
      form.style.transform = 'translateY(-20px)'
      
      setTimeout(() => {
        form.classList.add('hidden')
      }, 300)
    }
  }
  
  // Keep toggleAddForm as an alias for backward compatibility
  toggleAddForm() {
    this.toggleExperienceForm()
  }

  setupScrollAnimations() {
    // Intersection Observer for scroll animations
    const observerOptions = {
      threshold: 0.1,
      rootMargin: '0px 0px -50px 0px'
    }

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry) => {
        if (entry.isIntersecting) {
          entry.target.classList.add('animate-fade-in-up')
        }
      })
    }, observerOptions)

    // Observe all CV entries
    const entries = document.querySelectorAll('.cv-entry')
    entries.forEach((entry) => {
      observer.observe(entry)
    })
  }
  
  setupDragAndDrop() {
    console.log('Setting up drag and drop')
    
    if (!this.hasExperienceContainerTarget) {
      console.error('No experience container target found')
      return
    }
    
    if (!this.hasExperienceItemTargets) {
      console.error('No experience item targets found')
      return
    }
    
    console.log(`Found ${this.experienceItemTargets.length} experience items`)
    
    // Remove any existing event listeners
    const container = this.experienceContainerTarget
    const newContainer = container.cloneNode(false)
    
    // Preserve all children but reset event listeners
    while (container.firstChild) {
      newContainer.appendChild(container.firstChild)
    }
    
    // Replace the container with the new one
    container.parentNode.replaceChild(newContainer, container)
    
    // Wait for Stimulus to reconnect targets
    setTimeout(() => {
      this.initDragEvents()
    }, 100)
  }
  
  initDragEvents() {
    console.log('Initializing drag events')
    const container = this.experienceContainerTarget
    
    // Setup each draggable item
    this.experienceItemTargets.forEach(item => {
      console.log('Setting up drag for item:', item.dataset.id)
      
      // Make sure the item is draggable
      item.setAttribute('draggable', 'true')
      
      // Add a drag handle for better UX
      if (!item.querySelector('.drag-handle')) {
        const dragHandle = document.createElement('div')
        dragHandle.className = 'drag-handle absolute -left-6 top-0 h-full w-6 flex items-center justify-center cursor-move'
        dragHandle.innerHTML = '<svg class="w-4 h-4 text-gray-400" fill="currentColor" viewBox="0 0 24 24"><path d="M8 6a2 2 0 100-4 2 2 0 000 4zm0 8a2 2 0 100-4 2 2 0 000 4zm0 8a2 2 0 100-4 2 2 0 000 4zm8-16a2 2 0 100-4 2 2 0 000 4zm0 8a2 2 0 100-4 2 2 0 000 4zm0 8a2 2 0 100-4 2 2 0 000 4z"></path></svg>'
        item.prepend(dragHandle)
      }
      
      // Add hover effect
      item.addEventListener('mouseenter', () => {
        item.classList.add('bg-gray-50')
      })
      
      item.addEventListener('mouseleave', () => {
        item.classList.remove('bg-gray-50')
      })
      
      // Drag start event
      item.addEventListener('dragstart', (e) => {
        console.log('Drag started:', item.dataset.id)
        e.dataTransfer.effectAllowed = 'move'
        e.dataTransfer.setData('text/plain', item.dataset.id)
        
        // Add visual feedback
        item.classList.add('dragging')
        item.classList.add('border-2', 'border-dashed', 'border-blue-400', 'opacity-70')
        
        // Add a delay to make the visual effect visible
        setTimeout(() => {}, 0)
      })
      
      // Drag end event
      item.addEventListener('dragend', () => {
        console.log('Drag ended')
        item.classList.remove('dragging', 'border-2', 'border-dashed', 'border-blue-400', 'opacity-70')
        
        // Hide drop indicator
        this.hideDropIndicator()
      })
    })
    
    // Container events
    container.addEventListener('dragover', (e) => {
      e.preventDefault()
      e.dataTransfer.dropEffect = 'move'
      
      const draggingItem = document.querySelector('.dragging')
      if (!draggingItem) return
      
      // Get mouse position relative to container
      const containerRect = container.getBoundingClientRect()
      const y = e.clientY - containerRect.top
      
      // Find the closest item and position
      const { element: closestItem, position } = this.getDropPosition(container, y)
      
      // Show drop indicator at the right position
      if (closestItem) {
        this.showDropIndicator(closestItem, position)
      } else if (container.children.length > 0) {
        // If no closest item but container has children, append to end
        this.showDropIndicator(container.children[container.children.length - 1], 'after')
      }
    })
    
    // Drag leave event
    container.addEventListener('dragleave', (e) => {
      // Only hide if actually leaving the container
      if (e.relatedTarget && !container.contains(e.relatedTarget)) {
        this.hideDropIndicator()
      }
    })
    
    // Drop event
    container.addEventListener('drop', (e) => {
      e.preventDefault()
      console.log('Item dropped')
      
      // Hide the drop indicator
      this.hideDropIndicator()
      
      const id = e.dataTransfer.getData('text/plain')
      if (!id) {
        console.error('No ID found in drop event')
        return
      }
      
      const draggingItem = this.experienceItemTargets.find(item => item.dataset.id === id)
      if (!draggingItem) {
        console.error('Could not find dragging item with ID:', id)
        return
      }
      
      // Get mouse position relative to container
      const containerRect = container.getBoundingClientRect()
      const y = e.clientY - containerRect.top
      
      // Find the closest item and position
      const { element: closestItem, position } = this.getDropPosition(container, y)
      
      // Perform the DOM update
      if (closestItem) {
        if (position === 'before') {
          container.insertBefore(draggingItem, closestItem)
        } else {
          const nextSibling = closestItem.nextElementSibling
          if (nextSibling) {
            container.insertBefore(draggingItem, nextSibling)
          } else {
            container.appendChild(draggingItem)
          }
        }
      } else {
        container.appendChild(draggingItem)
      }
      
      // Get all experience items in their new order
      const positions = Array.from(this.experienceItemTargets).map(item => item.dataset.id)
      console.log('New positions:', positions)
      
      // Send the update to the server
      this.updateExperiencePositions(positions)
    })
  }
  
  getDropPosition(container, y) {
    // Get all items except the one being dragged
    const items = Array.from(container.children).filter(item => 
      !item.classList.contains('dragging') && 
      item.hasAttribute('data-cv-page-target') && 
      item.getAttribute('data-cv-page-target') === 'experienceItem'
    )
    
    // Find the closest item based on mouse position
    for (const item of items) {
      const box = item.getBoundingClientRect()
      const containerRect = container.getBoundingClientRect()
      const itemY = box.top - containerRect.top
      
      // If mouse is in the top half of the item, insert before
      if (y < itemY + box.height / 2) {
        return { element: item, position: 'before' }
      }
      
      // If mouse is in the bottom half and this is the last item, insert after
      if (y >= itemY + box.height / 2 && 
          items.indexOf(item) === items.length - 1) {
        return { element: item, position: 'after' }
      }
    }
    
    // If no suitable position found and there are items, insert after the last one
    if (items.length > 0) {
      return { element: items[items.length - 1], position: 'after' }
    }
    
    // If container is empty
    return { element: null, position: null }
  }
  
  showDropIndicator(element, position) {
    if (!this.dropIndicator) return
    
    const rect = element.getBoundingClientRect()
    
    this.dropIndicator.style.width = `${rect.width}px`
    this.dropIndicator.style.display = 'block'
    
    if (position === 'before') {
      this.dropIndicator.style.top = `${rect.top - 2}px`
      this.dropIndicator.style.left = `${rect.left}px`
    } else {
      this.dropIndicator.style.top = `${rect.bottom + 2}px`
      this.dropIndicator.style.left = `${rect.left}px`
    }
    
    // Add animation
    this.dropIndicator.style.transform = 'scaleX(1)'
    this.dropIndicator.style.opacity = '1'
  }
  
  hideDropIndicator() {
    if (!this.dropIndicator) return
    
    this.dropIndicator.style.transform = 'scaleX(0.5)'
    this.dropIndicator.style.opacity = '0'
    
    setTimeout(() => {
      this.dropIndicator.style.display = 'none'
    }, 200)
  }
  
  findClosestItem(y) {
    // Get all items except the one being dragged
    const items = this.experienceItemTargets.filter(item => !item.classList.contains('dragging'))
    
    // Find the closest item based on mouse position
    return items.reduce((closest, item) => {
      const box = item.getBoundingClientRect()
      const offset = y - box.top - box.height / 2
      
      if (offset < 0 && offset > closest.offset) {
        return { offset, element: item }
      } else {
        return closest
      }
    }, { offset: Number.NEGATIVE_INFINITY }).element
  }
  
  // This method has been replaced by findClosestItem
  
  updateExperiencePositions(positions) {
    console.log('Sending positions to server:', positions)
    
    // Get the CSRF token
    const csrfToken = document.querySelector('meta[name="csrf-token"]')
    
    if (!csrfToken) {
      console.error('CSRF token not found')
      alert('Could not reorder experiences: CSRF token missing')
      return
    }
    
    // Show a loading indicator
    const container = this.experienceContainerTarget
    container.classList.add('opacity-50')
    
    // Send the new positions to the server via fetch
    fetch('/cv_entries/reorder', {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-CSRF-Token': csrfToken.content
      },
      body: JSON.stringify({ positions: positions })
    })
    .then(response => {
      console.log('Server response status:', response.status)
      container.classList.remove('opacity-50')
      
      if (!response.ok) {
        return response.json().then(data => {
          console.error('Server error response:', data)
          throw new Error(data.error || 'Failed to update positions')
        })
      }
      return response.json()
    })
    .then(data => {
      console.log('Positions updated successfully:', data)
      
      // Update data-position attributes to match new order
      this.experienceItemTargets.forEach((item, index) => {
        item.dataset.position = index
      })
      
      // Flash success message
      const flashMessage = document.createElement('div')
      flashMessage.className = 'fixed top-4 right-4 bg-green-100 border-l-4 border-green-500 text-green-700 p-4 rounded shadow-md z-50'
      flashMessage.innerHTML = `<p>${data.message || 'Experiences reordered successfully'}</p>`
      document.body.appendChild(flashMessage)
      
      // Remove after 3 seconds
      setTimeout(() => {
        flashMessage.classList.add('opacity-0')
        setTimeout(() => {
          if (flashMessage.parentNode) {
            document.body.removeChild(flashMessage)
          }
        }, 300)
      }, 3000)
    })
    .catch(error => {
      console.error('Error updating positions:', error)
      
      // Revert the DOM to original order if there was an error
      // This is important to maintain consistency with the server state
      location.reload()
      
      // Show error message
      const errorMessage = document.createElement('div')
      errorMessage.className = 'fixed top-4 right-4 bg-red-100 border-l-4 border-red-500 text-red-700 p-4 rounded shadow-md z-50'
      errorMessage.innerHTML = `<p>${error.message}</p>`
      document.body.appendChild(errorMessage)
      
      // Remove after 5 seconds
      setTimeout(() => {
        errorMessage.classList.add('opacity-0')
        setTimeout(() => {
          if (errorMessage.parentNode) {
            document.body.removeChild(errorMessage)
          }
        }, 300)
      }, 5000)
    })
  }
}