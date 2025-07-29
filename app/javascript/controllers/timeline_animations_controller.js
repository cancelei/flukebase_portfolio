import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["entry"]

  connect() {
    console.log('Timeline animations controller connected')
    this.setupScrollAnimations()
  }

  setupScrollAnimations() {
    // Progressive timeline revelation
    const observerOptions = {
      threshold: 0.2,
      rootMargin: '0px 0px -100px 0px'
    }

    const observer = new IntersectionObserver((entries) => {
      entries.forEach((entry, index) => {
        if (entry.isIntersecting) {
          // Animate entry
          setTimeout(() => {
            entry.target.classList.add('timeline-reveal')
          }, index * 100)
          
          // Animate associated timeline dot
          const dot = entry.target.querySelector('.absolute.-left-12')
          if (dot) {
            setTimeout(() => {
              dot.classList.add('timeline-dot-reveal')
            }, index * 100 + 200)
          }
        }
      })
    }, observerOptions)

    this.entryTargets.forEach((entry) => {
      observer.observe(entry)
    })
  }
}