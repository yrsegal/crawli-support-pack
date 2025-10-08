InjectionHelper.defineMapPatch(201, 84, 4) { |page|
  page.patch(:eventiskill) {
    page.insertAtStart(:ExitEventProcessing)
    page.changeTrigger(:Interact)
  }
}
