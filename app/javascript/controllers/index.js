import { application } from "./application";

// Eagerly load controllers from the importmap
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading";
eagerLoadControllersFrom("controllers", application);
