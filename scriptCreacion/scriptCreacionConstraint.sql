---  TABLE cobros.archivo_detalle
ALTER TABLE cobros.archivo_detalle
ADD CONSTRAINT fk_archivodetalle_archivo FOREIGN KEY (co_archivo)
      REFERENCES cobros.archivo (co_archivo) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION

ALTER TABLE cobros.archivo_detalle
ADD  CONSTRAINT fk_archivodetalle_banco FOREIGN KEY (co_banco)
      REFERENCES cobros.banco (co_banco) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION

---  TABLE cobros.cuenta
ALTER TABLE cobros.cuenta
ADD CONSTRAINT fk_cuenta_banco FOREIGN KEY (co_banco)
      REFERENCES cobros.banco (co_banco) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION

---  TABLE cobros.cuota
ALTER TABLE cobros.cuota
ADD CONSTRAINT fk_cuota_banco FOREIGN KEY (co_banco)
      REFERENCES cobros.banco (co_banco) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION

ALTER TABLE cobros.cuota
ADD  CONSTRAINT fk_cuota_cuenta FOREIGN KEY (co_cuenta)
      REFERENCES cobros.cuenta (co_cuenta) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION

---  TABLE cobros.cuota_convenio
ALTER TABLE cobros.cuota_convenio
ADD CONSTRAINT cuotaconvenio_cuenta FOREIGN KEY (co_cuenta)
      REFERENCES cobros.cuenta (co_cuenta) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION

ALTER TABLE cobros.cuota_convenio
ADD CONSTRAINT fk_cuotaconvenio_banco FOREIGN KEY (co_banco)
      REFERENCES cobros.banco (co_banco) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION

ALTER TABLE cobros.cuota_convenio
ADD CONSTRAINT fk_cuotaconvenio_convenio FOREIGN KEY (co_convenio)
      REFERENCES cobros.convenio (co_convenio) MATCH FULL
      ON UPDATE NO ACTION ON DELETE NO ACTION



