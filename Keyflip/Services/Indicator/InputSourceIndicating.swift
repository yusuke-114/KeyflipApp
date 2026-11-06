//
//  InputSourceIndicating.swift
//  Keyflip
//

/// Tells the user which input source is in use after they move to another app.
protocol InputSourceIndicating: AnyObject {
    func show(_ source: InputSource, for app: AppIdentity)
}
