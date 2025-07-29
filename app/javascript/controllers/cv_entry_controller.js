import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { index: Number }

  connect() {
    console.log('CV Entry controller connected')
    this.setupHoverEffects()
    this.animateOnLoad()
  }

  setupHoverEffects() {
    this.element.addEventListener('mouseenter', () => {
      this.element.style.transform = 'translateY(-8px) scale(1.02)'
      
      // Animate timeline dot
      const dot = this.element.querySelector('.absolute.-left-12')
      if (dot) {
        dot.style.transform = 'scale(1.2)'
      }
    })

    this.element.addEventListener('mouseleave', () => {
      this.element.style.transform = 'translateY(0) scale(1)'
      
      // Reset timeline dot
      const dot = this.element.querySelector('.absolute.-left-12')
      if (dot) {
        dot.style.transform = 'scale(1)'
      }
    })
  }

  animateOnLoad() {
    // Stagger animation based on index
    const delay = this.indexValue * 150
    
    this.element.style.opacity = '0'
    this.element.style.transform = 'translateY(50px)'
    
    setTimeout(() => {
      this.element.style.transition = 'all 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94)'
      this.element.style.opacity = '1'
      this.element.style.transform = 'translateY(0)'
    }, delay)
  }
}